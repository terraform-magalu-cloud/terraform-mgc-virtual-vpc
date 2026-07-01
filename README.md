# Magalu Cloud VPC Network Module

## Description / Descrição

**EN-US:**
This is a production-ready, fully bilingual (en-US/pt-BR) Terraform/OpenTofu network module for Magalu Cloud (provider `MagaluCloud/mgc`). It is structured as a single monolithic module. All native parameters are exposed via `locals` and `dynamic blocks`, with zero required variables thanks to intelligent, contextual defaults. Extensive use of `validation`, `precondition`, and `postcondition` blocks ensures robust governance and security, with clear error messages in both languages. The unified Makefile orchestrates the full lifecycle, including documentation review, static/unit tests, and idempotent example validation. Breaking change mitigation and future resilience are built-in.

**PT-BR:**
Este é um módulo de rede Terraform/OpenTofu pronto para produção e totalmente bilíngue (en-US/pt-BR) para a Magalu Cloud (provider `MagaluCloud/mgc`). Estruturado como um módulo único monolítico. Todos os parâmetros nativos são expostos via `locals` e `dynamic blocks`, com zero variáveis obrigatórias graças a defaults inteligentes e contextualizados. Uso extensivo de blocos `validation`, `precondition` e `postcondition` garante governança e segurança rigorosas, com mensagens de erro claras nos dois idiomas. O Makefile unificado orquestra todo o ciclo de vida, incluindo revisão de documentação, testes estáticos/unitários e validação idempotente de exemplos. Mitigação de breaking changes e resiliência futura são nativos.

## Usage / Uso

```hcl
module "network" {
  source = "github.com/magalu-cloud/terraform-mgc-virtual-vpc"
  
  routes = {
    internet_route = {
      cidr_destination = "0.0.0.0/0"
      port_id          = "your-port-id"
      description      = "Internet bound traffic"
    }
  }
}
```

## Examples / Exemplos
- [examples/basic](examples/basic)
- [examples/complete](examples/complete)

## Breaking Change Mitigation / Mitigação de Breaking Changes
- Documented in CHANGELOG.md and README.md
- OPA/Rego policies for plan validation
- Extensive use of `lifecycle`, `ignore_changes`, and validation blocks

## License / Licença
MIT
