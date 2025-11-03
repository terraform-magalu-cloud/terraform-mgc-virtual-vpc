output "vpc_id" {
  description = "O ID da VPC de produção criada."
  value       = module.prod_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas."
  value       = [for subnet in module.prod_vpc.public_subnets : subnet.id]
}

output "private_subnet_ids" {
  description = "Lista de IDs das sub-redes privadas."
  value       = [for subnet in module.prod_vpc.private_subnets : subnet.id]
}

output "web_security_group_id" {
  description = "O ID do Security Group para a camada web."
  value       = module.prod_vpc.security_groups["web-sg"].id
}

output "app_security_group_id" {
  description = "O ID do Security Group para a camada de aplicação."
  value       = module.prod_vpc.security_groups["app-sg"].id
}

output "db_security_group_id" {
  description = "O ID do Security Group para a camada de banco de dados."
  value       = module.prod_vpc.security_groups["db-sg"].id
}

output "nat_gateway_ids" {
  description = "Lista de IDs dos NAT Gateways criados."
  value       = [for gw in module.prod_vpc.nat_gateways : gw.id]
}