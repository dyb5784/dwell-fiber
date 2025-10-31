package main

import (
	"math"
	"sync"
	"time"
)

type Controller struct {
	mu        sync.RWMutex
	Alpha     float64
	Budget    float64
	Price     float64
	Dwell     float64
	UpdatedAt time.Time
	Iteration int
	Scenario  string
}

func NewController(alpha, budget float64) *Controller {
	return &Controller{
		Alpha:     alpha,
		Budget:    budget,
		Price:     0.0,
		Dwell:     0.0,
		UpdatedAt: time.Now(),
		Scenario:  "normal",
	}
}

func (c *Controller) Update() {
	c.mu.Lock()
	defer c.mu.Unlock()

	// Simulate realistic dwell time patterns
	// This demonstrates how the system responds to different scenarios
	
	t := float64(c.Iteration)
	
	// Cycle through different scenarios every 100 iterations
	cycle := (c.Iteration / 100) % 4
	
	switch cycle {
	case 0:
		// Normal behavior: dwell time oscillates around budget
		c.Dwell = c.Budget + 2.0*math.Sin(t/10.0)
		c.Scenario = "normal"
		
	case 1:
		// Ransomware attack: sustained high dwell time
		c.Dwell = c.Budget + 3.0 + 0.5*math.Sin(t/5.0)
		c.Scenario = "attack"
		
	case 2:
		// Recovery: gradually decreasing dwell time
		progress := float64(c.Iteration % 100) / 100.0
		c.Dwell = c.Budget + 3.0*(1.0-progress) + 0.3*math.Sin(t/8.0)
		c.Scenario = "recovery"
		
	case 3:
		// Idle: low dwell time
		c.Dwell = c.Budget * 0.3 + 0.2*math.Sin(t/15.0)
		c.Scenario = "idle"
	}
	
	// Ensure dwell is non-negative
	if c.Dwell < 0 {
		c.Dwell = 0
	}

	// ADMM price update: price = max(0, price + α*(dwell - budget))
	violation := c.Dwell - c.Budget
	newPrice := c.Price + c.Alpha*violation

	// Project to non-negative orthant
	if newPrice < 0 {
		newPrice = 0
	}

	c.Price = newPrice
	c.UpdatedAt = time.Now()
	c.Iteration++
}

func (c *Controller) GetState() (float64, float64, time.Time, string) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.Price, c.Dwell, c.UpdatedAt, c.Scenario
}
