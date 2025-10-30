package main

import (
	"log"
	"net/http"
)

// StartMetricsServer starts a simple metrics HTTP server
func StartMetricsServer(port int) {
	http.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		w.Write([]byte("# Dwell-Fiber Metrics\n"))
		w.Write([]byte("# TODO: Implement Prometheus metrics\n"))
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK\n"))
	})

	addr := fmt.Sprintf(":%d", port)
	log.Printf("Metrics server listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Printf("Metrics server error: %v", err)
	}
}

import "fmt"
