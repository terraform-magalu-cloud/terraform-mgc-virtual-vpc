output "vpc_id" {
  description = "The ID of the VPC."
  value       = try(mgc_network_vpcs.this[0].id, null)
}

output "vpc_name" {
  description = "The name of the VPC."
  value       = try(mgc_network_vpcs.this[0].name, null)
}

output "vpc_description" {
  description = "The description of the VPC."
  value       = try(mgc_network_vpcs.this[0].description, null)
}

output "vpc" {
  description = "The full VPC resource object."
  value       = try(mgc_network_vpcs.this[0], null)
}

output "subnetpool_id" {
  description = "The ID of the Subnet Pool used (created or referenced)."
  value       = local.effective_subnetpool_id
}

output "subnetpool_cidr" {
  description = "The CIDR block of the Subnet Pool if created by this module."
  value       = try(mgc_network_subnetpools.this[0].cidr, var.subnetpool_cidr)
}

output "subnetpool" {
  description = "The full Subnet Pool resource object if created."
  value       = try(mgc_network_subnetpools.this[0], null)
}

output "subnets" {
  description = "Map of all subnet resource objects created in the VPC."
  value       = mgc_network_vpcs_subnets.this
}

output "subnet_ids" {
  description = "Map of subnet keys to their respective IDs."
  value       = { for k, v in mgc_network_vpcs_subnets.this : k => v.id }
}

output "subnet_cidr_blocks" {
  description = "Map of subnet keys to their respective CIDR blocks."
  value       = { for k, v in mgc_network_vpcs_subnets.this : k => v.cidr_block }
}

output "nat_gateways" {
  description = "Map of all NAT Gateway resource objects created."
  value       = mgc_network_nat_gateway.this
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway keys to their respective IDs."
  value       = { for k, v in mgc_network_nat_gateway.this : k => v.id }
}

output "security_groups" {
  description = "Map of all Security Group resource objects created."
  value       = mgc_network_security_groups.this
}

output "security_group_ids" {
  description = "Map of Security Group keys to their respective IDs."
  value       = { for k, v in mgc_network_security_groups.this : k => v.id }
}

output "security_group_rules" {
  description = "Map of all Security Group Rule resource objects created."
  value       = mgc_network_security_groups_rules.this
}

output "routes" {
  description = "Map of all Route resource objects created."
  value       = mgc_network_vpcs_route.this
}

output "route_ids" {
  description = "Map of Route keys to their respective IDs."
  value       = { for k, v in mgc_network_vpcs_route.this : k => v.id }
}

output "public_ips" {
  description = "Map of all Public IP resource objects created."
  value       = mgc_network_public_ips.this
}

output "public_ip_ids" {
  description = "Map of Public IP keys to their respective IDs."
  value       = { for k, v in mgc_network_public_ips.this : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of Public IP keys to their respective allocated IP addresses."
  value       = { for k, v in mgc_network_public_ips.this : k => v.public_ip }
}

output "tags" {
  description = "The tag attachment resource if tags were provided."
  value       = try(mgc_tag_attachment.this[0], null)
}
