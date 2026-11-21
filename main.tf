locals {
  vpc_id = try(mgc_network_vpcs.this[0].id, null)

  default_subnetpool_id = try([
    for sp in data.mgc_network_subnetpools.default[0].items : sp.id if sp.is_default
  ][0], null)

  effective_subnetpool_id = (
    var.create && var.create_subnetpool ? try(mgc_network_subnetpools.this[0].id, null) : (
      var.subnetpool_id != null ? var.subnetpool_id : (
        var.use_default_subnetpool ? local.default_subnetpool_id : null
      )
    )
  )

  first_subnet_az = try([
    for s in var.subnets : s.availability_zone if s.availability_zone != null
  ][0], null)

  default_nat_gateway_zone = var.nat_gateway_zone != null ? var.nat_gateway_zone : local.first_subnet_az

  nat_gateways = var.create ? (
    length(var.nat_gateways) > 0 ? var.nat_gateways : (
      var.enable_nat_gateway ? {
        "default" = {
          name              = coalesce(var.nat_gateway_name, "${var.name}-nat-gateway")
          description       = coalesce(var.nat_gateway_description, "NAT Gateway for ${var.name}")
          availability_zone = local.default_nat_gateway_zone
        }
      } : {}
    )
  ) : {}

  security_group_rules = flatten([
    for sg_key, sg in(var.create ? var.security_groups : {}) : [
      for rule_key, rule in coalesce(sg.rules, {}) : {
        key              = "${sg_key}-${rule_key}"
        sg_key           = sg_key
        description      = rule.description
        direction        = rule.direction
        ethertype        = rule.ethertype
        port_range_min   = rule.port_range_min
        port_range_max   = rule.port_range_max
        protocol         = rule.protocol
        remote_ip_prefix = rule.remote_ip_prefix
      }
    ]
  ])
}

# Optional lookup of tenant's default subnetpool
data "mgc_network_subnetpools" "default" {
  count = var.create && !var.create_subnetpool && var.use_default_subnetpool && var.subnetpool_id == null ? 1 : 0
}

# VPC
resource "mgc_network_vpcs" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  description = var.description
}

# Subnet Pool
resource "mgc_network_subnetpools" "this" {
  count = var.create && var.create_subnetpool ? 1 : 0

  name        = coalesce(var.subnetpool_name, "${var.name}-subnetpool")
  description = coalesce(var.subnetpool_description, "Subnet pool for ${var.name}")
  cidr        = var.subnetpool_cidr
}

# Subnets
resource "mgc_network_vpcs_subnets" "this" {
  for_each = var.create ? var.subnets : {}

  name              = coalesce(each.value.name, "${var.name}-${each.key}")
  vpc_id            = local.vpc_id
  subnetpool_id     = coalesce(each.value.subnetpool_id, local.effective_subnetpool_id)
  cidr_block        = each.value.cidr_block
  ip_version        = each.value.ip_version
  availability_zone = each.value.availability_zone
  description       = each.value.description
  dns_nameservers   = coalesce(each.value.dns_nameservers, var.default_dns_nameservers)
}

# NAT Gateways
resource "mgc_network_nat_gateway" "this" {
  for_each = local.nat_gateways

  name              = coalesce(each.value.name, "${var.name}-${each.key}-nat")
  description       = each.value.description
  vpc_id            = local.vpc_id
  availability_zone = each.value.availability_zone
}

# Security Groups
resource "mgc_network_security_groups" "this" {
  for_each = var.create ? var.security_groups : {}

  name                  = coalesce(each.value.name, "${var.name}-${each.key}-sg")
  description           = each.value.description
  disable_default_rules = each.value.disable_default_rules
}

# Security Group Rules
resource "mgc_network_security_groups_rules" "this" {
  for_each = {
    for rule in local.security_group_rules : rule.key => rule
  }

  security_group_id = mgc_network_security_groups.this[each.value.sg_key].id
  description       = each.value.description
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  protocol          = each.value.protocol
  remote_ip_prefix  = each.value.remote_ip_prefix
}

# VPC Routes
resource "mgc_network_vpcs_route" "this" {
  for_each = var.create ? var.routes : {}

  vpc_id           = local.vpc_id
  cidr_destination = each.value.cidr_destination
  description      = each.value.description
  peering_id       = each.value.peering_id
  port_id          = each.value.port_id
}

# Public IPs
resource "mgc_network_public_ips" "this" {
  for_each = var.create ? var.public_ips : {}

  vpc_id      = local.vpc_id
  description = each.value.description
}

# VPC Tags
resource "mgc_tag_attachment" "this" {
  count = var.create && length(var.tags) > 0 ? 1 : 0

  resource_id = local.vpc_id
  tags        = var.tags
}
