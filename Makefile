TOOLKIT = toolkit

# --- Dataset del repo -------------------------------------------------------
# datasets/  = dataset principali (una dir per dataset, ognuna con dataset.yml)
# support/   = anagrafiche/support (qui: ISTAT via external, nessun dataset.yml locale)
# I path relativi in dataset.yml sono risolti rispetto alla dir del file.

DATASETS := $(shell find datasets -name dataset.yml 2>/dev/null | sort)

.PHONY: check
check:
	@for f in $(DATASETS); do \
		echo "→ $$f"; \
		$(TOOLKIT) run preflight --config "$$f" || exit 1; \
	done
	@echo "✅ All configs valid"

.PHONY: run
run:
	@for f in $(DATASETS); do \
		echo "=== $$f ==="; \
		$(TOOLKIT) run --config "$$f" || exit 1; \
	done

# Support: ISTAT è external (GCS) — nessun seed locale da eseguire.
.PHONY: run-all
run-all: run

.PHONY: clean
clean:
	rm -rf out/data/_runs out/data/probe out/data/raw out/data/clean out/data/mart out/data/cross out/data/support .tmp/

.PHONY: registry
registry:
	$(TOOLKIT) registry build --prefix aci

.PHONY: registry-write
registry-write:
	$(TOOLKIT) registry build --prefix aci --write

.PHONY: test
test:
	pytest -q

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:' Makefile | sort
