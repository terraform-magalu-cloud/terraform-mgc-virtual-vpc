.PHONY: all fmt docs validate test test-verbose clean help

# Default target
all: fmt docs validate test

# Check or apply formatting
fmt:
	@echo "==> Formatting Terraform files..."
	terraform fmt -recursive

# Generate documentation with terraform-docs
docs:
	@echo "==> Generating documentation with terraform-docs..."
	terraform-docs .

# Validate configurations
validate:
	@echo "==> Validating root module..."
	terraform init -backend=false
	terraform validate
	@echo "==> Validating examples/simple..."
	cd examples/simple && terraform init -backend=false && terraform validate
	@echo "==> Validating examples/complete..."
	cd examples/complete && terraform init -backend=false && terraform validate

# Run native Terraform tests
test:
	@echo "==> Running Terraform tests..."
	terraform test

# Run tests with verbose output
test-verbose:
	@echo "==> Running Terraform tests (verbose)..."
	terraform test -verbose

# Clean temporary files
clean:
	@echo "==> Cleaning cache and lockfiles..."
	rm -rf .terraform examples/simple/.terraform examples/complete/.terraform

# Help target
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all          Run fmt, docs, validate, and test"
	@echo "  fmt          Format Terraform code"
	@echo "  docs         Generate README.md using terraform-docs"
	@echo "  validate     Validate root module and all examples"
	@echo "  test         Run unit tests using terraform test"
	@echo "  test-verbose Run unit tests with detailed output"
	@echo "  clean        Clean local .terraform directories"
