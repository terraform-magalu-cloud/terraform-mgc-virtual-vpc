output "vpc_id" {
  description = "The unique identifier of the deployed VPC"
  value       = module.complete_network.vpc_id
}

output "vpc_name" {
  description = "The name of the deployed VPC"
  value       = module.complete_network.vpc_name
}

output "default_nat_gateway_id" {
  description = "The ID of the default NAT Gateway"
  value       = module.complete_network.default_nat_gateway_id
}

output "custom_nat_gateway_ids" {
  description = "Map of custom NAT Gateway IDs"
  value       = module.complete_network.custom_nat_gateway_ids
}

output "subnetpool_id" {
  description = "The unique identifier of the deployed Subnet Pool"
  value       = module.complete_network.subnetpool_id
}

output "subnetpool_cidr" {
  description = "The CIDR block of the deployed Subnet Pool"
  value       = module.complete_network.subnetpool_cidr
}

output "subnet_ids" {
  description = "Map of deployed Subnet IDs"
  value       = module.complete_network.subnet_ids
}

output "subnet_cidrs" {
  description = "Map of deployed Subnet CIDR blocks"
  value       = module.complete_network.subnet_cidrs
}

output "route_ids" {
  description = "Map of deployed Route IDs"
  value       = module.complete_network.route_ids
}