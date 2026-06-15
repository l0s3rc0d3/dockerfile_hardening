DOCKERFILE    = Dockerfile
POLICY_DIR    = policy
HADOLINT_IMG  = ghcr.io/hadolint/hadolint
CONFTEST_IMG  = docker.io/openpolicyagent/conftest
CURRENT_DIR   = $(shell pwd)

.PHONY: all lint test help

all: lint test

lint:
	@echo "=== Running Hadolint ==="
	podman run --rm -i $(HADOLINT_IMG) < $(DOCKERFILE)
	@echo "Hadolint check passed successfully."

test:
	@echo "=== Running Conftest Policies ==="
	podman run --rm -v "$(CURRENT_DIR)":/workspace:z $(CONFTEST_IMG) test /workspace/$(DOCKERFILE) -p /workspace/$(POLICY_DIR) --namespace policy

help:
	@echo "Available commands:"
	@echo "  make       - Run both lint and test (default)"
	@echo "  make lint  - Run Hadolint analyzer"
	@echo "  make test  - Run Conftest policy checks"
	@echo "  make help  - Show this help message"
