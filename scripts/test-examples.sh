#!/bin/bash
set -e

EXAMPLES_DIR="examples"

for example in $(ls -d ${EXAMPLES_DIR}/*/ | grep -v 'examples/basic'); do
  echo "---"
  echo "--> Testing example: ${example}"
  
  (
  terraform -chdir="${example}" init -upgrade
  terraform -chdir="${example}" apply -auto-approve
  terraform -chdir="${example}" plan | grep "No changes." || {
    echo "EN-US: Idempotence check failed in ${example} | PT-BR: Checagem de idempotência falhou em ${example}"; exit 1;
  }
  terraform -chdir="${example}" destroy -auto-approve
  rm -f "${example}/tfplan"
  )

  echo "--> Test for ${example} PASSED"
  echo "---"
done