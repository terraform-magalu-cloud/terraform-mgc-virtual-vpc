output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs das sub-redes criadas."
  value       = module.vpc.subnet_ids
}

output "subnet_cidr_blocks" {
  description = "Blocos CIDR das sub-redes criadas."
  value       = module.vpc.subnet_cidr_blocks
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways criados."
  value       = module.vpc.nat_gateway_ids
}

output "route_ids" {
  description = "IDs das rotas configuradas."
  value       = module.vpc.route_ids
}

output "security_group_ids" {
  description = "IDs dos Security Groups criados."
  value       = module.vpc.security_group_ids
}

output "public_ip_addresses" {
  description = "Endereços IP públicos reservados para a VPC."
  value       = module.vpc.public_ip_addresses
}
