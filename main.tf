# Cria o Subnet Pool condicionalmente com base na variável 'create_subnetpool'
resource "mgc_network_subnetpools" "this" {
  count = var.create_subnetpool ? 1 : 0

  name        = "${var.vpc_name}-subnetpool"
  description = coalesce(var.subnetpool_description, "Subnet Pool for ${var.vpc_name}")
  cidr        = var.vpc_base_cidr
}

# Determina qual ID de Subnetpool usar: o recém-criado ou um existente
locals {
  effective_subnetpool_id = var.create_subnetpool ? mgc_network_subnetpools.this[0].id : var.subnetpool_id
}

# Cria o recurso principal da VPC
resource "mgc_network_vpcs" "this" {
  name        = var.vpc_name
  description = coalesce(var.vpc_description, "VPC for ${var.vpc_name} environment")
}

# Cria as sub-redes PÚBLICAS, uma para cada Zona de Disponibilidade
resource "mgc_network_vpcs_subnets" "public" {
  for_each = length(var.public_subnet_cidrs) > 0 ? toset(var.availability_zones) : toset([])

  vpc_id          = mgc_network_vpcs.this.id
  subnetpool_id   = local.effective_subnetpool_id
  name            = "${var.vpc_name}-public-${each.key}"
  description     = "Public subnet for ${var.vpc_name} in AZ ${each.key}"
  cidr_block      = var.public_subnet_cidrs[index(var.availability_zones, each.key)]
  availability_zone = each.key
  ip_version      = "IPv4"
}

# Cria as sub-redes PRIVADAS, uma para cada Zona de Disponibilidade
resource "mgc_network_vpcs_subnets" "private" {
  for_each = length(var.private_subnet_cidrs) > 0 ? toset(var.availability_zones) : toset([])

  vpc_id          = mgc_network_vpcs.this.id
  subnetpool_id   = local.effective_subnetpool_id
  name            = "${var.vpc_name}-private-${each.key}"
  description     = "Private subnet for ${var.vpc_name} in AZ ${each.key}"
  cidr_block      = var.private_subnet_cidrs[index(var.availability_zones, each.key)]
  availability_zone = each.key
  ip_version      = "IPv4"
}

# Cria os NAT Gateways, um para cada AZ, de forma condicional
resource "mgc_network_nat_gateway" "this" {
  for_each = var.create_nat_gateways ? toset(var.availability_zones) : toset([])

  name        = "${var.vpc_name}-nat-gw-${each.key}"
  description = "NAT Gateway for ${var.vpc_name} in AZ ${each.key}"
  vpc_id      = mgc_network_vpcs.this.id
  availability_zone = each.key

  depends_on = [mgc_network_vpcs_subnets.public]
}

# Cria os Security Groups com a opção 'disable_default_rules'
resource "mgc_network_security_groups" "this" {
  for_each = var.security_groups

  name                  = each.key
  description           = each.value.description
  disable_default_rules = each.value.disable_default_rules
}

# Lógica para "achatar" a estrutura de regras para o for_each do recurso de regras
locals {
  sg_rules_map = flatten([
    for sg_name, sg_config in var.security_groups : [
      for rule_index, rule_config in sg_config.rules : {
        rule_key           = "${sg_name}.${rule_index}"
        security_group_key = sg_name
        rule_data          = rule_config
      }
    ]
  ])
}

# Cria as regras para cada Security Group correspondente
resource "mgc_network_security_groups_rules" "this" {
  for_each = { for item in local.sg_rules_map : item.rule_key => item }

  security_group_id = mgc_network_security_groups.this[each.value.security_group_key].id
  description      = each.value.rule_data.description
  direction        = each.value.rule_data.direction
  ethertype        = each.value.rule_data.ethertype
  port_range_max   = each.value.rule_data.port_range_max
  port_range_min   = each.value.rule_data.port_range_min
  protocol         = each.value.rule_data.protocol
  remote_ip_prefix = each.value.rule_data.remote_ip_prefix
}