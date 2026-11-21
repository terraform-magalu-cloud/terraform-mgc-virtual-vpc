provider "mgc" {
  api_key = var.api_key
  region  = var.region
}

module "vpc" {
  source = "../../"

  name        = var.name
  description = "Exemplo simples de VPC com subnets publica e privada"

  # Subnet pool dedicada com CIDR /16
  create_subnetpool = true
  subnetpool_cidr   = "10.0.0.0/16"

  # Sub-redes da VPC
  subnets = {
    public = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede publica"
    }
    private = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede privada"
    }
  }
}
