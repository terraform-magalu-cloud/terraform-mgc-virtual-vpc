provider "mgc" {
  region = var.region
  api_key = = var.api_key
}

# --- INVOCAÇÃO DO MÓDULO mgc-ha-vpc ---
module "prod_vpc" {
  source = "../"

  # --- Configuração da Rede ---
  vpc_name              = "vpc-prod-webapp"
  vpc_description       = "VPC principal para a aplicação web de produção"
  vpc_base_cidr         = "10.100.0.0/16"
  availability_zones    = ["br-se1-a", "br-se1-b"]
  create_nat_gateways   = true

  public_subnet_cidrs = [
    "10.100.10.0/24", # AZ 'a'
    "10.100.11.0/24"  # AZ 'b'
  ]

  private_subnet_cidrs = [
    "10.100.100.0/24", # AZ 'a'
    "10.100.101.0/24"  # AZ 'b'
  ]

  # --- Definição dos Security Groups de Base ---
  security_groups = {
    # SG para Load Balancers e Web Servers na camada pública
    "web-sg" = {
      description           = "Permite tráfego web (HTTP/HTTPS) e SSH do Bastion"
      disable_default_rules = false
      rules = [
        {
          description      = "Permitir HTTPS de qualquer lugar"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 443
          port_range_max   = 443
          remote_ip_prefix = "0.0.0.0/0"
        },
        {
          description      = "Permitir SSH apenas do Bastion Host"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 22
          port_range_max   = 22
          remote_ip_prefix = var.bastion_host_ip
        }
      ]
    },

    # SG para Application Servers na camada privada
    "app-sg" = {
      description           = "Permite tráfego da camada web na porta da aplicação"
      disable_default_rules = false
      rules = [
        {
          description      = "Permitir tráfego da sub-rede pública A na porta 8080"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 8080
          port_range_max   = 8080
          remote_ip_prefix = "10.100.10.0/24" # CIDR da public-subnet-a
        },
        {
          description      = "Permitir tráfego da sub-rede pública B na porta 8080"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 8080
          port_range_max   = 8080
          remote_ip_prefix = "10.100.11.0/24" # CIDR da public-subnet-b
        }
      ]
    },
    
    # SG para Bancos de Dados na camada privada
    "db-sg" = {
      description           = "Permite tráfego da camada de aplicação na porta do PostgreSQL"
      disable_default_rules = true # Postura de segurança mais restrita: nega tudo por padrão
      rules = [
        {
          description      = "Permitir tráfego da sub-rede privada A na porta 5432"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 5432
          port_range_max   = 5432
          remote_ip_prefix = "10.100.100.0/24" # CIDR da private-subnet-a
        },
        {
          description      = "Permitir tráfego da sub-rede privada B na porta 5432"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 5432
          port_range_max   = 5432
          remote_ip_prefix = "10.100.101.0/24" # CIDR da private-subnet-b
        },
        {
          description      = "Permitir todo o tráfego de saída (necessário para updates, etc)"
          direction        = "egress"
          ethertype        = "IPv4"
          remote_ip_prefix = "0.0.0.0/0"
        }
      ]
    }
  }
}