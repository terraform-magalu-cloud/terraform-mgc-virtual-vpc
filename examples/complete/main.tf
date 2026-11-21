provider "mgc" {
  api_key = var.api_key
  region  = var.region
}

module "vpc" {
  source = "../../"

  name        = var.name
  description = "VPC de producao completa com multi-AZ NAT Gateway Security Groups e Rotas"

  # Subnet Pool dedicada com bloco /16
  create_subnetpool = true
  subnetpool_cidr   = "10.50.0.0/16"

  # Subnets multi-AZ (publicas e privadas em br-ne1-a e br-ne1-b)
  subnets = {
    public_1a = {
      cidr_block        = "10.50.1.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede publica na Zona de Disponibilidade A"
      dns_nameservers   = ["8.8.8.8", "1.1.1.1"]
    }
    private_1a = {
      cidr_block        = "10.50.2.0/24"
      availability_zone = "br-ne1-a"
      description       = "Sub-rede privada na Zona de Disponibilidade A"
    }
    public_1b = {
      cidr_block        = "10.50.3.0/24"
      availability_zone = "br-ne1-b"
      description       = "Sub-rede publica na Zona de Disponibilidade B"
      dns_nameservers   = ["8.8.8.8", "1.1.1.1"]
    }
    private_1b = {
      cidr_block        = "10.50.4.0/24"
      availability_zone = "br-ne1-b"
      description       = "Sub-rede privada na Zona de Disponibilidade B"
    }
  }

  # NAT Gateway para saida segura de trafego das sub-redes privadas
  enable_nat_gateway = true
  nat_gateway_zone   = "br-ne1-a"

  # Roteamento customizado: rota opcional caso seja informado um UUID de porta existente
  routes = var.route_appliance_port_id != null ? {
    to_corp_network = {
      cidr_destination = "172.16.0.0/12"
      description      = "Encaminha trafego corporativo para interface de firewall ou appliance"
      port_id          = var.route_appliance_port_id
    }
  } : {}

  # Grupos de seguranca e regras granulares de firewall
  security_groups = {
    web = {
      name                  = "${var.name}-web-sg"
      description           = "Regras de acesso para camada de borda e web"
      disable_default_rules = false
      rules = {
        http = {
          description      = "Entrada HTTP publica"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 80
          port_range_max   = 80
          remote_ip_prefix = "0.0.0.0/0"
        }
        https = {
          description      = "Entrada HTTPS publica"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 443
          port_range_max   = 443
          remote_ip_prefix = "0.0.0.0/0"
        }
      }
    }
    db = {
      name                  = "${var.name}-db-sg"
      description           = "Regras de acesso para banco de dados interno"
      disable_default_rules = true
      rules = {
        postgres = {
          description      = "Acesso PostgreSQL apenas a partir das subnets da VPC"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 5432
          port_range_max   = 5432
          remote_ip_prefix = "10.50.0.0/16"
        }
      }
    }
  }

  # Reserva de IP Publico para Load Balancer ou Ingress
  public_ips = {
    ingress_ip = {
      description = "IP Publico dedicado para o Ingress Controller ou Load Balancer"
    }
  }
}
