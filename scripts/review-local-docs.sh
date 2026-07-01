#!/bin/bash
set -e

# EN-US: Script to dynamically find and review local Terraform provider documentation.
# PT-BR: Script para encontrar e revisar dinamicamente a documentação local do provider Terraform.

echo "EN-US: Searching for local Magalu Cloud provider documentation..."
echo "PT-BR: Buscando documentação local do provider Magalu Cloud..."

# EN-US: Dynamically find the docs directory, ignoring OS/Arch and Version specifics.
# PT-BR: Encontra dinamicamente o diretório docs, ignorando especificidades de SO/Arch e Versão.
DOCS_DIR=$(find .terraform/providers/registry.terraform.io/magalucloud/mgc -type d -name "docs" | head -n 1)

if [ -z "$DOCS_DIR" ]; then
  echo "EN-US: Documentation not found. Please run 'make init' first."
  echo "PT-BR: Documentação não encontrada. Por favor, execute 'make init' primeiro."
  exit 1
fi

echo "====================================================="
echo "EN-US: Documentation found at: / PT-BR: Documentação encontrada em:"
echo "$DOCS_DIR"
echo "====================================================="

echo "EN-US: Available Resources / PT-BR: Recursos Disponíveis:"
find "$DOCS_DIR/resources" -type f -name "*.md" -exec basename {} .md \; | sed 's/^/ - /' || echo "  N/A"

echo ""
echo "EN-US: Available Data Sources / PT-BR: Data Sources Disponíveis:"
find "$DOCS_DIR/data-sources" -type f -name "*.md" -exec basename {} .md \; | sed 's/^/ - /' || echo "  N/A"

echo ""
echo "====================================================="
echo "EN-US: Checking for 'Deprecated' notices in Markdown... / PT-BR: Verificando avisos de 'Depreciado' no Markdown..."
grep -rni "deprecated" "$DOCS_DIR" | sed 's/^/ - /' || echo "  EN-US: No deprecations found. / PT-BR: Nenhuma depreciação encontrada."

if [ -n "$1" ]; then
  echo "====================================================="
  echo "EN-US: Searching for '$1' in Markdown docs... / PT-BR: Buscando por '$1' na documentação Markdown..."
  grep -rni "$1" "$DOCS_DIR" | sed 's/^/ - /' || echo "  EN-US: Not found. / PT-BR: Não encontrado."
fi