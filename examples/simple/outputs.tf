output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs das subnets criadas no formato chave => id."
  value       = module.vpc.subnet_ids
}

output "subnetpool_id" {
  description = "ID da Subnet Pool utilizada."
  value       = module.vpc.subnetpool_id
}
