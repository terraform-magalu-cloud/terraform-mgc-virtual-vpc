resource "mgc_network_vpcs" "this" {
  count       = var.create ? 1 : 0
  name        = var.name
  description = var.description
}

resource "mgc_network_subnetpools" "this" {
  for_each    = length(var.subnetpool) > 0 ? { for pool in var.subnetpool : pool.name => pool } : {}
  name        = each.value.name
  description = each.value.description
  cidr        = each.value.cidr
}

resource "mgc_network_security_groups" "this" {
  count                 = var.security_group.create ? 1 : 0
  name                  = "Security Group ${var.name}"
  description           = "An security group to ${var.security_group.description}"
  disable_default_rules = false
}

resource "mgc_network_security_groups_rules" "this" {
  depends_on        = [mgc_network_security_groups.this]
  for_each          = length(var.security_group.rules) > 0 ? { for rule in var.security_group.rules : "${rule.protocol}-${rule.port_min}-${rule.port_max}" => rule } : {}
  description       = each.value.description
  direction         = each.value.egress ? "egress" : "ingress"
  ethertype         = "IPv${each.value.ipv}"
  port_range_max    = each.value.port_max
  port_range_min    = each.value.port_min
  protocol          = each.value.protocol
  remote_ip_prefix  = each.value.cidr
  security_group_id = mgc_network_security_groups.this[0].id
}

resource "mgc_network_nat_gateway" "this" {
  depends_on        = [mgc_network_vpcs.this]
  for_each          = var.nat_gateway.create ? toset(var.nat_gateway.availability_zone) : toset([])
  name              = "${var.nat_gateway.name}-${each.key}"
  vpc_id            = mgc_network_vpcs.this[0].id
  availability_zone = each.key
  description       = "${var.nat_gateway.description} in AZ ${each.key}"
}

locals {
  subnets_map = {
    for subnet in var.subnets : subnet.name => subnet
  }
}

resource "mgc_network_vpcs_subnets" "this" {
  # O for_each agora itera sobre o mapa 'local.subnets_map' que acabamos de criar.
  for_each          = local.subnets_map
  vpc_id            = mgc_network_vpcs.this[0].id
  subnetpool_id     = mgc_network_subnetpools.this[each.value.subnetpool_name].id
  name              = each.value.name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  description       = each.value.description
  dns_nameservers   = each.value.dns_nameservers
  ip_version        = "IPv${each.value.ip_version}"
}



resource "mgc_network_vpcs_route" "this" {
  for_each = length(var.routes) > 0 ? toset(var.nat_gateway.availability_zone) : toset([])
  vpc_id           = mgc_network_vpcs.this[0].id
  port_id          = mgc_network_nat_gateway.this[each.key].id
  cidr_destination = "0.0.0.0/0"
  description      = "Route example"
}