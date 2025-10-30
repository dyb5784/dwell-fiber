package main

import (
	"context"
	"flag"
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

	// Validate parameters
	if *alpha <= 0 || *alpha >= 2 {
		log.Fatalf("Invalid alpha: %f (must be 0 < α < 2)", *alpha)
	}

	log.Printf("Dwell-Fiber daemon starting...")
	log.Printf("  Alpha (step size): %.2f", *alpha)
	log.Printf("  Budget: %.2f seconds", *budget)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Initialize controller
	ctrl := &Controller{
		Alpha:     *alpha,
		Budget:    *budget,
		Price:     0.0,
		Dwell:     0.0,
		UpdatedAt: time.Now(),
	}

	// Start BPF monitoring
	log.Println("Loading BPF program...")
	if err := ctrl.LoadBPF(); err != nil {
		log.Fatalf("Failed to load BPF: %v", err)
	}
	defer ctrl.UnloadBPF()

	// Start metrics server
	go StartMetricsServer(*port)

	// Start control loop
	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()

	// Handle signals
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	log.Println("Daemon running. Press Ctrl+C to stop.")

	for {
		select {
		case <-ticker.C:
			if err := ctrl.UpdatePrice(ctx); err != nil {
				log.Printf("Error updating price: %v", err)
			}

		case <-sigCh:
			log.Println("Shutting down...")
			return

		case <-ctx.Done():
			return
		}
	}
}
