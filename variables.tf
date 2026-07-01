variable "create" {
  description = "VPC create by module"
  type        = bool
  default     = true
}
variable "name" {
  type        = string
  description = "O nome único para a VPC. Este é o único parâmetro obrigatório."
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "O nome da VPC deve consistir em letras minúsculas, números e hífens, e começar e terminar com uma letra ou número."
  }
}

variable "description" {
  type        = string
  description = "Descrição opcional para a VPC."
  default     = "VPC adicional"
}

variable "subnetpool" {
  type = list(object({
    name        = string
    description = string
    cidr        = string
  }))
  description = "Configuração do Subnet Pool. Por padrão, cria um pool com um CIDR /16."
  default = [
    {
      name        = "default-subnetpool"
      description = "Default Subnet Pool"
      cidr        = "172.31.0.0/16"
    }
  ]
}
variable "security_group" {
  type = object({
    create      = bool
    name        = string
    description = string
    # --- CORREÇÃO APLICADA AQUI ---
    # Alterado de "rule" para "rules" para corresponder ao bloco default e seguir as boas práticas.
    rules = list(object({
      description = string
      egress      = bool
      ipv         = number
      protocol    = string
      port_min    = number
      port_max    = number
      cidr        = string
    }))
  })
  description = "Configuração do Security Group. Por padrão, cria um SG com regras de saída liberadas."

  # O seu bloco default agora está correto e compatível com o 'type' acima.
  default = {
    create      = true
    name        = "default-security-group"
    description = "Default Security Group"
    rules = [
      {
        description = "Liberação da rede interna"
        egress      = false
        ipv         = 4
        protocol    = "tcp"
        port_min    = 2
        port_max    = 65535
        cidr        = "0.0.0.0/0"
      },
      # Regra de saída explícita, necessária porque desabilitamos as regras padrão
      {
        description = "Liberado a qualquer serviço da rede internta porta alta"
        egress      = true
        ipv         = 4
        protocol    = "tcp"
        port_min    = 1
        port_max    = 65535
        cidr        = "0.0.0.0/0"
      },
      {
        description = "Liberado a qualquer serviço da rede internta porta alta"
        egress      = true
        ipv         = 4
        protocol    = "udp"
        port_min    = 1
        port_max    = 65535
        cidr        = "0.0.0.0/0"
      },
    ]
  }
}

variable "subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
    subnetpool_name   = string
    ip_version        = number
    dns_nameservers   = list(string)
    description       = string
  }))
  description = "Mapa de sub-redes a serem criadas. Por padrão, nenhuma sub-rede é criada."
  default = [{
    name              = "public-subnet"
    cidr_block        = "172.31.1.0/24"
    availability_zone = "br-se1-a"
    subnetpool_name   = "default-subnetpool"
    ip_version        = 4
    dns_nameservers   = ["8.8.8.8", "8.8.4.4"]
    description       = "Public subnet"
    },
    {
      name              = "private-subnet"
      cidr_block        = "172.31.2.0/24"
      availability_zone = "br-se1-b"
      subnetpool_name   = "default-subnetpool"
      ip_version        = 4
      dns_nameservers   = ["8.8.8.8", "8.8.4.4"]
      description       = "Private subnet"
  }]
}

variable "nat_gateway" {
  type = object({
    create            = bool
    name              = string
    description       = string
    availability_zone = list(string)
  })
  description = "Configuração do NAT Gateway. Por padrão, não cria nenhum NAT Gateway."
  default = {
    create            = false
    name              = "default-nat-gateway"
    description       = "Default NAT Gateway"
    availability_zone = ["br-se1-a", "br-se1-b", "br-se1-c"]
  }
}

variable "routes" {
  type = list(object({
    port_id           = string
    cidr_destination  = string
    availability_zone = string
    description       = string
  }))
  description = "Lista de rotas estáticas a serem criadas. Por padrão, nenhuma rota adicional é criada."
  default  = []
}