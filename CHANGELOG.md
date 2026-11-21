# Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.

## [1.0.0] - 2026-11-20

### Funcionalidades

* **vpc:** Lançamento inicial do módulo VPC para Magalu Cloud (`terraform-mgc-virtual-vpc`).
* **subnetpool:** Criação automática de Subnet Pool dedicada com bloco CIDR `/16`, suporte a Subnet Pool pré-existente e resolução automática do pool padrão do tenant.
* **subnets:** Gerenciamento dinâmico de sub-redes multi-AZ com suporte a CIDRs customizados, servidores DNS (`8.8.8.8`, `8.8.4.4`) e protocolos IPv4/IPv6.
* **nat-gateway:** Conectividade de saída segura para a internet em sub-redes privadas com auto-inferência da Zona de Disponibilidade (AZ).
* **security-groups:** Gerenciamento granular de grupos de segurança com regras de firewall de entrada (*ingress*) e saída (*egress*).
* **routes:** Tabela de rotas customizadas para conexões de VPC Peering e portas de interfaces virtuais de rede (`port_id`).
* **public-ips:** Alocação e gerenciamento de IPs públicos vinculados à VPC.
* **tags:** Suporte a anexação de tags da Magalu Cloud (`mgc_tag_attachment`) aos recursos da VPC.
* **validations:** Validações nativas do Terraform para blocos CIDR, versões IP, UUIDs, direções de regras de firewall e conformidade de descrições da API MGC.
* **testing:** Suíte de testes unitários automatizada com o framework nativo `terraform test` e mocks (100% offline e sem custos de nuvem).
* **examples:** Exemplos práticos prontos para execução em `examples/simple` e `examples/complete`.
* **ci-cd:** Automação completa com `Makefile` (`make test`, `make fmt`, `make validate`, `make all`) e pipelines do GitHub Actions para testes, notificações via Telegram e Semantic Release.
