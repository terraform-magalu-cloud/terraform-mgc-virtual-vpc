# Terraform Module: MGC High-Availability VPC

Este módulo provisiona uma infraestrutura de rede de alta disponibilidade (HA) na Magalu Cloud, incluindo VPC, sub-redes, NAT Gateways e Security Groups.

## Funcionalidades

- Cria uma VPC (Virtual Private Cloud).
- Cria condicionalmente um Subnet Pool.
- Cria sub-redes públicas e privadas distribuídas em múltiplas Zonas de Disponibilidade (AZs).
- Cria condicionalmente NAT Gateways em cada AZ para acesso de saída das sub-redes privadas.
- Cria opcionalmente um conjunto de Security Groups, com controle sobre as regras padrão.

## Exemplo de Utilização

```hcl
module "ha_vpc_prod" {
  source = "./modules/mgc-ha-vpc"

  # --- Configuração da Rede ---
  vpc_name              = "vpc-prod-app"
  vpc_base_cidr         = "10.30.0.0/16"
  availability_zones    = ["br-se1-a", "br-se1-b"]
  create_nat_gateways   = true

  public_subnet_cidrs = [
    "10.30.1.0/24",
    "10.30.2.0/24"
  ]
  private_subnet_cidrs = [
    "10.30.101.0/24",
    "10.30.102.0/24"
  ]

  # --- Definição Opcional dos Security Groups ---
  security_groups = {
    "web-sg" = {
      description           = "Allows inbound web and SSH traffic"
      disable_default_rules = false
      rules = [
        {
          description      = "Allow SSH from bastion"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 22
          port_range_max   = 22
          remote_ip_prefix = "1.2.3.4/32"
        }
      ]
    },
    "db-sg" = {
      description           = "Strict security for database tier"
      disable_default_rules = true
      rules = [
        # ...
      ]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_mgc"></a> [mgc](#requirement\_mgc) | ~> 0.39 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mgc"></a> [mgc](#provider\_mgc) | ~> 0.39 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mgc_network_nat_gateway.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_nat_gateway) | resource |
| [mgc_network_security_groups.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_security_groups) | resource |
| [mgc_network_security_groups_rules.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_security_groups_rules) | resource |
| [mgc_network_subnetpools.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_subnetpools) | resource |
| [mgc_network_vpcs.this](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs) | resource |
| [mgc_network_vpcs_subnets.private](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs_subnets) | resource |
| [mgc_network_vpcs_subnets.public](https://registry.terraform.io/providers/MagaluCloud/mgc/latest/docs/resources/network_vpcs_subnets) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | A list of Availability Zones to create subnets in. HA requires at least two. | `list(string)` | n/a | yes |
| <a name="input_create_nat_gateways"></a> [create\_nat\_gateways](#input\_create\_nat\_gateways) | If true, creates a NAT Gateway in each Availability Zone's public subnet to provide outbound internet access for private subnets. | `bool` | `false` | no |
| <a name="input_create_subnetpool"></a> [create\_subnetpool](#input\_create\_subnetpool) | If true, a new Subnet Pool will be created. If false, an existing 'subnetpool\_id' must be provided. | `bool` | `true` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | A list of CIDR blocks for the private subnets. Must have the same number of elements as 'availability\_zones'. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | A list of CIDR blocks for the public subnets. Must have the same number of elements as 'availability\_zones'. | `list(string)` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A map of Security Groups to be created within the VPC. The map key is used as the SG name. | <pre>map(object({<br>    description           = string<br>    disable_default_rules = optional(bool, false)<br>    rules = list(object({<br>      description      = string<br>      direction        = string<br>      ethertype        = string<br>      port_range_min   = optional(number)<br>      port_range_max   = optional(number)<br>      protocol         = optional(string)<br>      remote_ip_prefix = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_subnetpool_description"></a> [subnetpool\_description](#input\_subnetpool\_description) | A custom description for the Subnet Pool resource. | `string` | `null` | no |
| <a name="input_subnetpool_id"></a> [subnetpool\_id](#input\_subnetpool\_id) | The ID of an existing Subnet Pool to use. Required if 'create\_subnetpool' is false. | `string` | `""` | no |
| <a name="input_vpc_base_cidr"></a> [vpc\_base\_cidr](#input\_vpc\_base\_cidr) | The base CIDR block for the entire VPC, used to create the Subnet Pool. Required if 'create\_subnetpool' is true. | `string` | `""` | no |
| <a name="input_vpc_description"></a> [vpc\_description](#input\_vpc\_description) | A custom description for the VPC resource. | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | A base name for the VPC and its resources. Must be unique. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateways"></a> [nat\_gateways](#output\_nat\_gateways) | A map of the created NAT Gateways, keyed by their Availability Zone. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | A map of the created private subnets, keyed by their Availability Zone. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | A map of the created public subnets, keyed by their Availability Zone. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | A map of the created security groups, keyed by their short name. Contains the ID and name of each SG. |
| <a name="output_subnetpool_id"></a> [subnetpool\_id](#output\_subnetpool\_id) | The ID of the Subnet Pool being used. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The unique identifier of the created VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the created VPC. |
<!-- END_TF_DOCS -->