package main

import (
	"fmt"
	"math"
	"sync"
	"time"

	"github.com/dyb5784/dwell-fiber/pkg/enforcement"
	"github.com/prometheus/client_golang/prometheus"
)

type Controller struct {
	Alpha  float64 // Exported for metrics
	Budget float64 // Exported for metrics
	mu     sync.RWMutex

	// State
	currentPrice float64
	lastUpdate   time.Time
	scenario     string

	// Real BPF tracking
	dwellMap map[int]*DwellInfo // PID -> dwell info

	// Recent dwell times for averaging
	recentDwells []float64
	maxRecent    int

	// Enforcement
	enforcer *enforcement.Enforcer

	// Metrics
	dwellGauge      prometheus.Gauge
	priceGauge      prometheus.Gauge
	throttledGauge  prometheus.Gauge
	killedGauge     prometheus.Gauge
	enforcementMode prometheus.Gauge
}

type DwellInfo struct {
	PID       int
	Cmd       string
	OpenTime  time.Time
	CloseTime time.Time
	Dwell     time.Duration
}

func NewController(alpha, budget float64) *Controller {
	// Create enforcement config - default to DISABLED (observation mode)
	enfConfig := enforcement.DefaultConfig()
	enfConfig.Enabled = false // Start in dry-run mode
	enfConfig.ThrottleThreshold = 5 * time.Second
	enfConfig.ThrottleCPUQuota = 20
	enfConfig.KillThreshold = 15 * time.Second
	enfConfig.KillEnabled = false

	c := &Controller{
		Alpha:        alpha,
		Budget:       budget,
		currentPrice: 0.1,
		lastUpdate:   time.Now(),
		scenario:     "real-bpf",
		dwellMap:     make(map[int]*DwellInfo),
		recentDwells: make([]float64, 0),
		maxRecent:    10, // Keep last 10 measurements
		enforcer:     enforcement.NewEnforcer(enfConfig),
		dwellGauge: prometheus.NewGauge(prometheus.GaugeOpts{
			Name: "dwell_fiber_dwell_time",
			Help: "Current average file dwell time (seconds)",
		}),
		priceGauge: prometheus.NewGauge(prometheus.GaugeOpts{
			Name: "dwell_fiber_price",
			Help: "Current access price",
		}),
		throttledGauge: prometheus.NewGauge(prometheus.GaugeOpts{
			Name: "dwell_fiber_throttled_count",
			Help: "Number of currently throttled processes",
		}),
		killedGauge: prometheus.NewGauge(prometheus.GaugeOpts{
			Name: "dwell_fiber_killed_count",
			Help: "Number of killed processes",
		}),
		enforcementMode: prometheus.NewGauge(prometheus.GaugeOpts{
			Name: "dwell_fiber_enforcement_enabled",
			Help: "Enforcement mode (0=dry-run, 1=enabled)",
		}),
	}

	prometheus.MustRegister(c.dwellGauge)
	prometheus.MustRegister(c.priceGauge)
	prometheus.MustRegister(c.throttledGauge)
	prometheus.MustRegister(c.killedGauge)
	prometheus.MustRegister(c.enforcementMode)

	return c
}

func (c *Controller) HandleOpenEvent(pid int, cmd string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.dwellMap[pid] = &DwellInfo{
		PID:      pid,
		Cmd:      cmd,
		OpenTime: time.Now(),
	}
}

func (c *Controller) HandleCloseEvent(pid int) {
	c.mu.Lock()
	defer c.mu.Unlock()

	info, exists := c.dwellMap[pid]
	if !exists {
		return
	}

	info.CloseTime = time.Now()
	info.Dwell = info.CloseTime.Sub(info.OpenTime)

	// Filter out noise: only process events > 1 seconds
	if info.Dwell < 1*time.Second {
		return // Silently skip noise
	}

	// Log high-dwell events for visibility
	fmt.Printf("⏱️  High dwell: PID=%d (%s) dwell=%.2fs\n", pid, info.Cmd, info.Dwell.Seconds())

	// Store dwell time for averaging
	dwellSeconds := info.Dwell.Seconds()
	c.recentDwells = append(c.recentDwells, dwellSeconds)

	// Keep only recent measurements - limit to last 10 events
	if len(c.recentDwells) > 10 {
		c.recentDwells = c.recentDwells[1:]
	}

	// Apply enforcement for significant dwell
	if info.Dwell > time.Second {
		if err := c.enforcer.Enforce(info.PID, info.Cmd, info.Dwell); err != nil {
			fmt.Printf("⚠️  Enforcement error: %v\n", err)
		}
	}

	// Update metrics
	avgDwell := c.calculateAverageDwell()
	c.dwellGauge.Set(avgDwell)

	// Update price using ADMM
	c.updatePrice(avgDwell)
	c.priceGauge.Set(c.currentPrice)
	c.lastUpdate = time.Now()

	// Update enforcement metrics
	throttled, killed := c.enforcer.GetStats()
	c.throttledGauge.Set(float64(throttled))
	c.killedGauge.Set(float64(killed))
}

func (c *Controller) calculateAverageDwell() float64 {
	if len(c.recentDwells) == 0 {
		return 0
	}

	var total float64
	for _, dwell := range c.recentDwells {
		total += dwell
	}

	return total / float64(len(c.recentDwells))
}

func (c *Controller) updatePrice(avgDwell float64) {
	// ADMM price update: p(t+1) = p(t) + α(d(t) - budget)
	violation := avgDwell - c.Budget
	newPrice := c.currentPrice + c.Alpha*violation
	c.currentPrice = math.Max(0, newPrice)
}

func (c *Controller) RunCleanup() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		c.mu.Lock()

		// Cleanup enforcement tracking
		c.enforcer.Cleanup()

		// Cleanup old dwell entries
		cutoff := time.Now().Add(-1 * time.Minute)
		for pid, info := range c.dwellMap {
			if info.OpenTime.Before(cutoff) && info.CloseTime.IsZero() {
				delete(c.dwellMap, pid)
			}
		}

		c.mu.Unlock()
	}
}

// GetState returns state for metrics (4 values for compatibility)
func (c *Controller) GetState() (price float64, dwell float64, updated time.Time, scenario string) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.currentPrice, c.calculateAverageDwell(), c.lastUpdate, c.scenario
}

// RunSimulation generates fake events for testing
func (c *Controller) RunSimulation() {
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	
	scenarios := []struct {
		cmd   string
		dwell time.Duration
	}{
		{"bash", 1 * time.Second},
		{"vim", 3 * time.Second},
		{"python", 2 * time.Second},
		{"chrome", 6 * time.Second}, // Should trigger throttling
		{"firefox", 4 * time.Second},
		{"gcc", 8 * time.Second}, // Should trigger throttling
	}
	
	i := 0
	for range ticker.C {
		scenario := scenarios[i%len(scenarios)]
		pid := 1000 + i // Fake PID
		
		// Simulate open event
		c.HandleOpenEvent(pid, scenario.cmd)
		
		// Simulate close event after dwell time
		go func(pid int, cmd string, dwell time.Duration) {
			time.Sleep(dwell)
			c.HandleCloseEvent(pid)
			fmt.Printf("📊 Simulated: PID=%d (%s) dwell=%.2fs\n", pid, cmd, dwell.Seconds())
		}(pid, scenario.cmd, scenario.dwell)
		
		i++
	}
}
