COQC := coqc
COQFLAGS := -R . DwellFiber

VFILES := dwell_stable.v
VOFILES := $(VFILES:.v=.vo)

.PHONY: all clean

all: $(VOFILES)

%.vo: %.v
	$(COQC) $(COQFLAGS) $<

clean:
	rm -f $(VOFILES) .*.aux *.glob .*.cache
