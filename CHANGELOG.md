# Breaking Change Mitigation Plan / Plano de Mitigação de Breaking Changes

**EN-US:**
- All provider documentation is compulsorily reviewed before coding (`make doc-review`).
- OPA/Rego policies are used to block deprecated/unsafe arguments in plans.
- All resources use `lifecycle` with `ignore_changes` for non-critical fields.
- All module variables and outputs are versioned and described in both languages.
- A CHANGELOG.md is maintained for every breaking change, with migration steps.
- Example scenarios are validated on every change (`make test-examples`).
- Defaults are always backward compatible and safe.

**PT-BR:**
- Toda documentação do provider é revisada obrigatoriamente antes de codificar (`make doc-review`).
- Políticas OPA/Rego bloqueiam argumentos depreciados/inseguros no plano.
- Todos os recursos usam `lifecycle` com `ignore_changes` para campos não críticos.
- Todas as variáveis e outputs dos módulos são versionadas e descritas nos dois idiomas.
- Um CHANGELOG.md é mantido para cada breaking change, com passos de migração.
- Cenários de exemplo são validados a cada alteração (`make test-examples`).
- Defaults são sempre retrocompatíveis e seguros.
