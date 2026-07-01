terraform {
  required_version = ">= 1.6.0"
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = ">= 0.51.0"
    }
  }
}

provider "mgc" {
  region  = "br-se1"
  api_key = var.api_key
}

module "complete_network" {
  source = "../../"

  # Parâmetros de VPC
  create_vpc      = true
  existing_vpc_id = null
  vpc_name        = "corp-complete-vpc"
  vpc_description = "Complete corporate VPC deployed with exhaustive configuration"

  # Parâmetros de NAT Gateway
  create_nat_gateway = true
  availability_zone  = "br-se1-a"
  nat_gateways = {
    secondary_nat = {
      name              = "corp-nat-gateway-secondary"
      description       = "Secondary NAT Gateway for redundancy"
      availability_zone = "br-se1-b"
    }
  }

  # Parâmetros de Subnet Pool
  create_subnetpool        = true
  existing_subnetpool_id   = null
  existing_subnetpool_cidr = null
  subnetpool_name          = "corp-complete-subnetpool"
  subnetpool_description   = "Complete Subnet Pool managed via Terraform"
  subnetpool_cidr          = "10.100.0.0/16"

  # Parâmetros de Subnets
  subnets = {
    public_subnet = {
      name              = "corp-public-subnet"
      cidr_block        = "10.100.1.0/24"
      ip_version        = "IPv4"
      availability_zone = "br-se1-a"
      description       = "Public facing subnet"
      dns_nameservers   = ["8.8.8.8", "1.1.1.1"]
    }
    private_subnet = {
      name              = "corp-private-subnet"
      cidr_block        = "10.100.2.0/24"
      ip_version        = "IPv4"
      availability_zone = "br-se1-b"
      description       = "Private backend subnet"
      dns_nameservers   = ["8.8.4.4", "1.0.0.1"]
    }
  }

  # Parâmetros de Rotas
  enable_routes = true

  routes = {
    internet_outbound = {
      cidr_destination = "0.0.0.0/0"
      port_id          = var.external_port_id
      description      = "Default route to the internet"
    }
    internal_peering = {
      cidr_destination = "192.168.0.0/16"
      port_id          = var.internal_port_id
      description      = "Route to internal peered network"
    }
  }
}