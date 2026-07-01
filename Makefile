# Makefile
SHELL := /bin/bash

# Detecta dinamicamente todos os subdiretórios dentro de examples/
EXAMPLES_DIRS := $(wildcard examples/*/)
# Remove caminhos relativos para obter apenas os nomes das pastas (ex: basic, advanced)
EXAMPLES_NAMES := $(patsubst examples/%/,%,$(EXAMPLES_DIRS))

# Define DIR dinamicamente como o primeiro exemplo encontrado se o usuário não passar DIR explicitamente
DIR ?= $(firstword $(EXAMPLES_DIRS))

.PHONY: all init plan apply destroy clean fmt validate docs pre-commit lint test test-examples policy-check doc-review security upgrade-test destroy-test examples validate-examples

# Alvo principal de integração local
all: lint test docs

init:
	@echo "EN-US: Initializing root module... | PT-BR: Inicializando módulo raiz..."
	terraform init -upgrade
	@echo ""
	@echo "EN-US: Checking local provider Markdown documentation folder... | PT-BR: Verificando pasta de documentação Markdown local do provider..."
	@find .terraform/providers/registry.terraform.io/magalucloud/mgc -type d -name "docs" 2>/dev/null || echo "WARNING: Local documentation folder not found yet."
	@echo ""
	@echo "EN-US: Initializing example directory in $(DIR)... | PT-BR: Inicializando diretório de exemplo em $(DIR)..."
	@if [ -d "$(DIR)" ]; then \
		terraform -chdir=$(DIR) init -upgrade; \
	else \
		echo "ERROR: Target directory '$(DIR)' does not exist."; \
		exit 1; \
	fi

plan:
	@echo "EN-US: Generating execution plan in $(DIR)... | PT-BR: Gerando plano de execução em $(DIR)..."
		@echo "[init] Forçando download do provider mais estável..."
		cd $(DIR) && terraform init -upgrade && cd -

	terraform -chdir=$(DIR) plan

apply:
	@echo "EN-US: Applying changes in $(DIR)... | PT-BR: Aplicando mudanças em $(DIR)..."
	terraform -chdir=$(DIR) apply -auto-approve

destroy:
	@echo "EN-US: Destroying resources in $(DIR)... | PT-BR: Destruindo recursos em $(DIR)..."
	terraform -chdir=$(DIR) destroy -auto-approve

fmt:
	@echo "EN-US: Formatting Terraform files recursively... | PT-BR: Formatando arquivos Terraform recursivamente..."
	terraform fmt -recursive

validate:
	@echo "EN-US: Validating root and $(DIR) configurations... | PT-BR: Validando configurações do raiz e de $(DIR)..."
	terraform validate
	@if [ -d "$(DIR)" ]; then \
		terraform -chdir=$(DIR) validate; \
	fi

clean:
	@echo "EN-US: Cleaning up cache files, state records and lock files... | PT-BR: Limpando arquivos de cache (.terraform), locks e estados..."
	find . -type d -name ".terraform" -prune -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "*.tfstate" -delete
	find . -type f -name "*.tfstate.backup" -delete
	find . -type f -name "tfplan.binary" -delete
	find . -type f -name "tfplan.json" -delete

lint:
	@echo "EN-US: Running code styling and static analysis... | PT-BR: Executando linters e verificação de estilo..."
	terraform fmt -check -recursive
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init && tflint --recursive; \
	else \
		echo "WARNING: 'tflint' is not installed. Skipping HCL deep linting."; \
	fi

test:
	@echo "EN-US: Running native root unit tests... | PT-BR: Executando testes unitários nativos do módulo raiz..."
	terraform test

test-examples:
	@echo "[test-examples] Validando idempotência dos exemplos..."
	bash scripts/test-examples.sh

validate-examples:
	@echo "EN-US: Running backend-less validation across all examples... | PT-BR: Executando validação sintática rápida em todos os exemplos..."
	@for dir in $(EXAMPLES_DIRS) ; do \
		echo "Validating $$dir"; \
		terraform -chdir=$$dir init -backend=false > /dev/null; \
		terraform -chdir=$$dir validate || exit 1; \
	done

test-examples:
	@echo "EN-US: Executing native test assertion suites in examples... | PT-BR: Executando testes do Terraform (tftest) nos cenários de exemplos..."
	@for dir in $(EXAMPLES_DIRS) ; do \
		echo "Testing $$dir"; \
		terraform -chdir=$$dir init -upgrade > /dev/null; \
		terraform -chdir=$$dir test || exit 1; \
	done

security:
	@echo "EN-US: Analyzing configuration security standards... | PT-BR: Executando análise estática de segurança..."
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "WARNING: 'tfsec' is not installed. Skipping tfsec scanning."; \
	fi
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d . --quiet; \
	else \
		echo "WARNING: 'checkov' is not installed. Skipping checkov scanning."; \
	fi

upgrade-test:
	@echo "EN-US: Executing target-level plan transition test... | PT-BR: Executando testes de transição de plano no alvo $(DIR)..."
	$(MAKE) plan DIR=$(DIR)

doc-review:
	@echo "EN-US: Auditing local provider markdown documentation... | PT-BR: Revisando documentação local do provider..."
	@DOC_DIR=$$(find .terraform/providers/registry.terraform.io/magalucloud/mgc -type d -name "docs" 2>/dev/null | head -n 1); \
	if [ -z "$$DOC_DIR" ]; then \
		echo "EN-US: ERROR: Local documentation folder not found. Run 'make init' first. | PT-BR: ERRO: Pasta de documentação local não encontrada. Rode 'make init' primeiro."; \
		exit 1; \
	fi; \
	echo "Docs folder path: $$DOC_DIR"; \
	if [ -n "$(SEARCH)" ]; then \
		echo "Searching for '$(SEARCH)' inside local files..."; \
		grep -rnwi "$$DOC_DIR" -e "$(SEARCH)" --include=\*.md || echo "No matches found."; \
	else \
		echo "No SEARCH term provided. Listing all available documentation files:"; \
		find "$$DOC_DIR" -name "*.md" | sed "s|.*/||" | sort; \
		echo ""; \
		echo "Usage / Uso: make doc-review SEARCH=<resource_or_attribute_name>"; \
	fi

policy-check:
	@echo "EN-US: Running OPA governance policy check on $(DIR)... | PT-BR: Verificando conformidade com a política OPA em $(DIR)..."
	@if command -v opa >/dev/null 2>&1; then \
		terraform -chdir=$(DIR) init -upgrade > /dev/null; \
		terraform -chdir=$(DIR) plan -out=tfplan.binary > /dev/null; \
		terraform -chdir=$(DIR) show -json tfplan.binary > $(DIR)/tfplan.json; \
		if [ -f policy.rego ]; then \
			opa eval -i $(DIR)/tfplan.json -d policy.rego "data.tfplan.mgc.deny"; \
		else \
			echo "policy.rego not found at root."; \
		fi; \
		rm -f $(DIR)/tfplan.binary $(DIR)/tfplan.json; \
	else \
		echo "WARNING: OPA (opa) CLI tool is not installed. Skipping policy compliance check."; \
	fi

pre-commit:
	@echo "EN-US: Running pre-commit validation loops... | PT-BR: Executando pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "ERROR: 'pre-commit' is not installed."; \
		exit 1; \
	fi

docs:
	@echo "EN-US: Regenerating variable markdown tables in README.md... | PT-BR: Gerando tabelas de parâmetros no README.md..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md --output-mode inject .; \
	else \
		echo "WARNING: 'terraform-docs' is not installed. Manual readme updates may be required."; \
	fi

destroy-test:
	$(MAKE) destroy DIR=$(DIR)

# ==============================================================================
# DYNAMIC PATTERN RULES (Regras Dinâmicas de Execução Direta)
# ==============================================================================
# Permite rodar comandos para qualquer exemplo sem digitar caminhos completos.
# Exemplos de uso:
#   make plan-basic
#   make apply-advanced
#   make destroy-basic
# ==============================================================================

init-%:
	@echo "EN-US: Initializing example: $*... | PT-BR: Inicializando o exemplo: $*..."
	terraform -chdir=examples/$* init -upgrade

plan-%:
	@echo "EN-US: Planning configuration for: $*... | PT-BR: Planejando a configuração para: $*..."
	terraform -chdir=examples/$* plan

apply-%:
	@echo "EN-US: Appyling changes for: $*... | PT-BR: Aplicando as alterações para: $*..."
	terraform -chdir=examples/$* apply -auto-approve

destroy-%:
	@echo "EN-US: Destroying resources for: $*... | PT-BR: Destruindo recursos de: $*..."
	terraform -chdir=examples/$* destroy -auto-approve

validate-%:
	@echo "EN-US: Syntactically validating: $*... | PT-BR: Validando sintaxe de: $*..."
	terraform -chdir=examples/$* validate

test-%:
	@echo "EN-US: Running HCL tftest assertions for: $*... | PT-BR: Rodando asserções de tftest para: $*..."
	terraform -chdir=examples/$* test

policy-check-%:
	@echo "EN-US: Checking OPA policy compliance for: $*... | PT-BR: Verificando conformidade OPA para: $*..."
	@if command -v opa >/dev/null 2>&1; then \
		terraform -chdir=examples/$* init -upgrade > /dev/null; \
		terraform -chdir=examples/$* plan -out=tfplan.binary > /dev/null; \
		terraform -chdir=examples/$* show -json tfplan.binary > examples/$*/tfplan.json; \
		if [ -f policy.rego ]; then \
			opa eval -i examples/$*/tfplan.json -d policy.rego "data.tfplan.mgc.deny"; \
		else \
			echo "policy.rego not found at root."; \
		fi; \
		rm -f examples/$*/tfplan.binary examples/$*/tfplan.json; \
	else \
		echo "WARNING: OPA is not installed. Skipping policy compliance check."; \
	fi