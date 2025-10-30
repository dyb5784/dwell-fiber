.PHONY: all clean test verify ci

all: bpf daemon coq

bpf:
	@echo "Building eBPF programs..."
	@\ -C bpf

daemon: bpf
	@echo "Building Go daemon..."
	@cd daemon && go build -o ../bin/dwell-fiber-daemon .

coq:
	@echo "Compiling Coq proofs..."
	@\ -C coq

verify: coq
	@echo "Verifying proofs..."
	@coqchk -silent -R coq DwellFiber dwell_stable

test:
	@echo "Running tests..."
	@cd daemon && go test ./...
	@cd pkg && go test ./...

ci: verify test
	@echo "✓ All CI checks passed"

clean:
	@\ -C bpf clean
	@\ -C coq clean
	@rm -rf bin/
	@cd daemon && go clean
