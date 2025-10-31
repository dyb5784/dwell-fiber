package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var (
	alpha  = flag.Float64("alpha", 0.5, "ADMM step size (0 < α < 2)")
	budget = flag.Float64("budget", 5.0, "Dwell time budget in seconds")
	port   = flag.Int("port", 9090, "Metrics port")
)

func main() {
	flag.Parse()

	if *alpha <= 0 || *alpha >= 2 {
		log.Fatalf("Invalid alpha: %f (must be 0 < α < 2)", *alpha)
	}

	fmt.Printf("🛡️  Dwell-Fiber Daemon Starting\n")
	fmt.Printf("   Alpha: %.2f\n", *alpha)
	fmt.Printf("   Budget: %.2f seconds\n", *budget)
	fmt.Printf("   Metrics: http://localhost:%d\n", *port)
	fmt.Printf("   Web UI: http://localhost:%d (auto-refresh)\n", *port)
	fmt.Println()

	ctrl := NewController(*alpha, *budget)

	// Start metrics server
	go StartMetricsServer(*port, ctrl)

	// Control loop
	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	log.Println("✓ Daemon running (Press Ctrl+C to stop)")
	log.Println("✓ Demonstrating 4 scenarios in cycles:")
	log.Println("  1. Normal: Dwell oscillates around budget")
	log.Println("  2. Attack: High dwell (simulated ransomware)")
	log.Println("  3. Recovery: Gradually decreasing")
	log.Println("  4. Idle: Low activity")

	for {
		select {
		case <-ticker.C:
			ctrl.Update()
		case <-sigCh:
			log.Println("Shutting down...")
			return
		}
	}
}
