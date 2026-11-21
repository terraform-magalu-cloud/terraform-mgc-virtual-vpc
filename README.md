<img title="Magalu Cloud" alt="Logo da Magalu Cloud" src="https://raw.githubusercontent.com/terraform-magalu-cloud/.github/61d26ff88c3d74c97d46c0957afd36894b8bbed1/profile/img/magalu.png" width="100" height="100">  <img title="Terraform" alt="Logo do Terraform" src="https://raw.githubusercontent.com/terraform-magalu-cloud/.github/61d26ff88c3d74c97d46c0957afd36894b8bbed1/profile/img/terraform.png" width="100" height="100">

# Terraform Module: Magalu Cloud VPC (`terraform-mgc-virtual-vpc`)

[![Release](https://img.shields.io/badge/release-v1.0.0-blue.svg)](https://github.com/terraform-magalu-cloud/terraform-mgc-virtual-vpc/releases)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4.svg)](https://www.terraform.io/)
[![Magalu Cloud](https://img.shields.io/badge/Provider%20MGC-%3E%3D0.56.0-0086FF.svg)](https://registry.terraform.io/providers/MagaluCloud/mgc/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

Módulo Terraform oficial da comunidade para provisionamento, orquestração e gerenciamento confiável e versátil de **VPC (Virtual Private Cloud)** e seus componentes de rede na **Magalu Cloud (MGC)**.

## Recursos Suportados

- **VPC (`mgc_network_vpcs`)**: Criação da rede privada virtual isolada.
- **Subnet Pools (`mgc_network_subnetpools`)**: Suporte a 3 estratégias flexíveis:
  1. Criação automática de Subnet Pool dedicada (`create_subnetpool = true`).
  2. Uso de um Subnet Pool pré-existente (`subnetpool_id = "..."`).
  3. Resolução automática do Subnet Pool padrão do Tenant (`use_default_subnetpool = true`).
- **Subnets (`mgc_network_vpcs_subnets`)**: Provisionamento dinâmico de múltiplas sub-redes com validação de CIDR, AZs e DNS customizado.
- **NAT Gateway (`mgc_network_nat_gateway`)**: Conectividade de saída segura para a internet em sub-redes privadas com auto-inferência de AZ.
- **Security Groups e Regras (`mgc_network_security_groups` / `mgc_network_security_groups_rules`)**: Firewall virtual para portas e protocolos com validação de regras.
- **Rotas de VPC (`mgc_network_vpcs_route`)**: Suporte a roteamento customizado para VPC Peering ou interfaces virtuais (portas).
- **IPs Públicos (`mgc_network_public_ips`)**: Alocação de IPs públicos atrelados à VPC.
- **Tags (`mgc_tag_attachment`)**: Anexação opcional de tags MGC à VPC.
- **Validações Nativas**: Blocos `validation` para garantir integridade de CIDRs, versões de IP, regras de firewall e rotas antes do provisionamento.
- **Framework de Testes Nativo**: Cobertura de testes unitários com `terraform test` e `mock_provider`.

## Como Usar

### 1. Uso Básico (VPC com Subnet Pool e Subnets)

Veja o código executável completo em [examples/simple](examples/simple):

```terraform
module "vpc" {
  source  = "terraform-magalu-cloud/virtual-vpc/mgc"
  version = "1.0.0"

  name        = "my-app-vpc"
  description = "VPC para aplicacao principal"

  # Subnet pool dedicada com CIDR /16
  create_subnetpool = true
  subnetpool_cidr   = "10.0.0.0/16"

  # Sub-redes da VPC
  subnets = {
    public-1a = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede publica na AZ a"
    }
    private-1a = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede privada na AZ a"
    }
  }
}
```

### 2. Uso Completo (com NAT Gateway, Security Groups e IP Público)

Veja o código executável completo em [examples/complete](examples/complete):

```terraform
module "vpc" {
  source  = "terraform-magalu-cloud/virtual-vpc/mgc"
  version = "1.0.0"

  name        = "production-vpc"
  description = "VPC de producao com NAT Gateway e Security Groups"

  # Pool de sub-redes
  create_subnetpool = true
  subnetpool_cidr   = "10.10.0.0/16"

  # Subnets multi-AZ
  subnets = {
    public-1a = {
      cidr_block        = "10.10.1.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede publica na AZ a"
      dns_nameservers   = ["8.8.8.8", "1.1.1.1"]
    }
    private-1a = {
      cidr_block        = "10.10.2.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede privada na AZ a"
    }
  }

  # Habilita NAT Gateway para conexao externa da sub-rede privada
  enable_nat_gateway = true
  nat_gateway_zone   = "br-ne1-a"

  # Grupos de seguranca e regras
  security_groups = {
    web = {
      description = "Security group para servidores web"
      rules = {
        http = {
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 80
          port_range_max   = 80
          remote_ip_prefix = "0.0.0.0/0"
        }
        https = {
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 443
          port_range_max   = 443
          remote_ip_prefix = "0.0.0.0/0"
        }
      }
    }
  }

  # IP publico para a VPC
  public_ips = {
    web_ip = {
      description = "IP publico para o balancer ou web"
    }
  }
}
```

## Testes e Validação

O módulo conta com uma suíte de testes unitários automatizados utilizando o framework nativo `terraform test` com mocks (`mock_provider`):

```bash
# Executar todos os testes
make test

# Executar testes com saída detalhada
make test-verbose

# Validar formatação e sintaxe de todos os módulos
make fmt
make validate
```

## Summary
This module was created and maintained by the community. If you want to help, see how to do this by accessing the repository:
[terraform-magalu-cloud/how-can-help](https://github.com/terraform-magalu-cloud/how-can-help)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_mgc"></a> [mgc](#requirement\_mgc) | >= 0.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mgc"></a> [mgc](#provider\_mgc) | >= 0.56.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mgc_network_nat_gateway.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_nat_gateway) | resource |
| [mgc_network_public_ips.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_public_ips) | resource |
| [mgc_network_security_groups.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_security_groups) | resource |
| [mgc_network_security_groups_rules.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_security_groups_rules) | resource |
| [mgc_network_subnetpools.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_subnetpools) | resource |
| [mgc_network_vpcs.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs) | resource |
| [mgc_network_vpcs_route.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs_route) | resource |
| [mgc_network_vpcs_subnets.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs_subnets) | resource |
| [mgc_tag_attachment.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/tag_attachment) | resource |
| [mgc_network_subnetpools.default](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/data-sources/network_subnetpools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the VPC. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Defines whether resources in this module will be created. | `bool` | `true` | no |
| <a name="input_create_subnetpool"></a> [create\_subnetpool](#input\_create\_subnetpool) | Defines whether a dedicated Subnet Pool should be created for this VPC. | `bool` | `true` | no |
| <a name="input_default_dns_nameservers"></a> [default\_dns\_nameservers](#input\_default\_dns\_nameservers) | Default DNS nameservers for subnets if not specified individually. | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "8.8.4.4"<br>]</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the VPC. Must only contain letters (A-Z, a-z), numbers (0-9), spaces, and hyphens (-). | `string` | `null` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Defines whether to create a default NAT Gateway for the VPC. | `bool` | `false` | no |
| <a name="input_nat_gateway_description"></a> [nat\_gateway\_description](#input\_nat\_gateway\_description) | Description of the default NAT Gateway. | `string` | `null` | no |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | Name of the default NAT Gateway. If null and enable\_nat\_gateway is true, defaults to '<name>-nat-gateway'. | `string` | `null` | no |
| <a name="input_nat_gateway_zone"></a> [nat\_gateway\_zone](#input\_nat\_gateway\_zone) | Availability zone for the default NAT Gateway (e.g. 'br-ne1-a'). If null, falls back to the availability zone of the first configured subnet. | `string` | `null` | no |
| <a name="input_nat_gateways"></a> [nat\_gateways](#input\_nat\_gateways) | Map of NAT Gateways to create within the VPC. If provided, takes precedence over enable\_nat\_gateway single gateway creation. | <pre>map(object({<br>    name              = optional(string)<br>    description       = optional(string)<br>    availability_zone = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_public_ips"></a> [public\_ips](#input\_public\_ips) | Map of public IPs to allocate for this VPC. | <pre>map(object({<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of custom routes to add to the VPC route table (e.g. for VPC peering or network ports). | <pre>map(object({<br>    cidr_destination = string<br>    description      = optional(string)<br>    peering_id       = optional(string)<br>    port_id          = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of security groups and their associated rules to create in the VPC. | <pre>map(object({<br>    name                  = optional(string)<br>    description           = optional(string)<br>    disable_default_rules = optional(bool, false)<br>    rules = optional(map(object({<br>      description      = optional(string)<br>      direction        = string<br>      ethertype        = optional(string, "IPv4")<br>      port_range_min   = optional(number)<br>      port_range_max   = optional(number)<br>      protocol         = optional(string, "tcp")<br>      remote_ip_prefix = optional(string, "0.0.0.0/0")<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_subnetpool_cidr"></a> [subnetpool\_cidr](#input\_subnetpool\_cidr) | The CIDR block of the Subnet Pool. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_subnetpool_description"></a> [subnetpool\_description](#input\_subnetpool\_description) | The description of the Subnet Pool. If null and create\_subnetpool is true, defaults to 'Subnet pool for <name>'. | `string` | `null` | no |
| <a name="input_subnetpool_id"></a> [subnetpool\_id](#input\_subnetpool\_id) | An existing Subnet Pool ID to use when create\_subnetpool is false. | `string` | `null` | no |
| <a name="input_subnetpool_name"></a> [subnetpool\_name](#input\_subnetpool\_name) | The name of the Subnet Pool. If null and create\_subnetpool is true, defaults to '<name>-subnetpool'. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets to create within the VPC. Key is used as subnet identifier. | <pre>map(object({<br>    name              = optional(string)<br>    cidr_block        = string<br>    ip_version        = optional(string, "IPv4")<br>    availability_zone = optional(string)<br>    description       = optional(string)<br>    dns_nameservers   = optional(list(string))<br>    subnetpool_id     = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional map of tags to attach to the VPC resource. | `map(string)` | `{}` | no |
| <a name="input_use_default_subnetpool"></a> [use\_default\_subnetpool](#input\_use\_default\_subnetpool) | Whether to look up and use the tenant's default Subnet Pool if create\_subnetpool is false and subnetpool\_id is null. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | Map of NAT Gateway keys to their respective IDs. |
| <a name="output_nat_gateways"></a> [nat\_gateways](#output\_nat\_gateways) | Map of all NAT Gateway resource objects created. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | Map of Public IP keys to their respective allocated IP addresses. |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | Map of Public IP keys to their respective IDs. |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Map of all Public IP resource objects created. |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of Route keys to their respective IDs. |
| <a name="output_routes"></a> [routes](#output\_routes) | Map of all Route resource objects created. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of Security Group keys to their respective IDs. |
| <a name="output_security_group_rules"></a> [security\_group\_rules](#output\_security\_group\_rules) | Map of all Security Group Rule resource objects created. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | Map of all Security Group resource objects created. |
| <a name="output_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#output\_subnet\_cidr\_blocks) | Map of subnet keys to their respective CIDR blocks. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet keys to their respective IDs. |
| <a name="output_subnetpool"></a> [subnetpool](#output\_subnetpool) | The full Subnet Pool resource object if created. |
| <a name="output_subnetpool_cidr"></a> [subnetpool\_cidr](#output\_subnetpool\_cidr) | The CIDR block of the Subnet Pool if created by this module. |
| <a name="output_subnetpool_id"></a> [subnetpool\_id](#output\_subnetpool\_id) | The ID of the Subnet Pool used (created or referenced). |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of all subnet resource objects created in the VPC. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tag attachment resource if tags were provided. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The full VPC resource object. |
| <a name="output_vpc_description"></a> [vpc\_description](#output\_vpc\_description) | The description of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC. |