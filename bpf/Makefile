CLANG ?= clang
ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')

BPF_CFLAGS := -target bpf -D__TARGET_ARCH_$(ARCH) -g -O2 -Wall
BPF_INCLUDES := -I/usr/include -I/usr/include/$(shell uname -m)-linux-gnu

TARGETS := dwell_monitor.bpf.o

.PHONY: all clean

all: $(TARGETS)

%.bpf.o: %.bpf.c
	$(CLANG) $(BPF_CFLAGS) $(BPF_INCLUDES) -c $< -o $@

clean:
	rm -f $(TARGETS)
