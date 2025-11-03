output "vpc_id" {
  description = "The unique identifier of the created VPC."
  value       = mgc_network_vpcs.this.id
}

output "vpc_name" {
  description = "The name of the created VPC."
  value       = mgc_network_vpcs.this.name
}

output "subnetpool_id" {
  description = "The ID of the Subnet Pool being used."
  value       = local.effective_subnetpool_id
}

output "public_subnets" {
  description = "A map of the created public subnets, keyed by their Availability Zone."
  value = {
    for az, subnet in mgc_network_vpcs_subnets.public : az => {
      id         = subnet.id
      name       = subnet.name
      cidr_block = subnet.cidr_block
    }
  }
}

output "private_subnets" {
  description = "A map of the created private subnets, keyed by their Availability Zone."
  value = {
    for az, subnet in mgc_network_vpcs_subnets.private : az => {
      id         = subnet.id
      name       = subnet.name
      cidr_block = subnet.cidr_block
    }
  }
}

output "nat_gateways" {
  description = "A map of the created NAT Gateways, keyed by their Availability Zone."
  value = {
    for az, gw in mgc_network_nat_gateway.this : az => {
      id   = gw.id
      name = gw.name
    }
  }
}

output "security_groups" {
  description = "A map of the created security groups, keyed by their short name. Contains the ID and name of each SG."
  value = {
    for key, sg in mgc_network_security_groups.this : key => {
      id   = sg.id
      name = sg.name
    }
  }
  sensitive = true
}