#------------------------------------------------------------------------------
# VPC e Nomenclatura Principal
#------------------------------------------------------------------------------
variable "vpc_name" {
  type        = string
  description = "A base name for the VPC and its resources. Must be unique."
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.vpc_name))
    error_message = "The VPC name must consist of lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_description" {
  type        = string
  description = "A custom description for the VPC resource."
  default     = null
}

#------------------------------------------------------------------------------
# Controle e Configuração do Subnetpool
#------------------------------------------------------------------------------
variable "create_subnetpool" {
  type        = bool
  description = "If true, a new Subnet Pool will be created. If false, an existing 'subnetpool_id' must be provided."
  default     = true
}

variable "subnetpool_id" {
  type        = string
  description = "The ID of an existing Subnet Pool to use. Required if 'create_subnetpool' is false."
  default     = ""
}

variable "vpc_base_cidr" {
  type        = string
  description = "The base CIDR block for the entire VPC, used to create the Subnet Pool. Required if 'create_subnetpool' is true."
  default     = ""
}

variable "subnetpool_description" {
  type        = string
  description = "A custom description for the Subnet Pool resource."
  default     = null
}

#------------------------------------------------------------------------------
# Configuração de Sub-redes e NAT Gateways para HA
#------------------------------------------------------------------------------
variable "availability_zones" {
  type        = list(string)
  description = "A list of Availability Zones to create subnets in. HA requires at least two."
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "For High Availability, please provide at least two Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks for the public subnets. Must have the same number of elements as 'availability_zones'."
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks for the private subnets. Must have the same number of elements as 'availability_zones'."
  default     = []
}

variable "create_nat_gateways" {
  type        = bool
  description = "If true, creates a NAT Gateway in each Availability Zone's public subnet to provide outbound internet access for private subnets."
  default     = false # Opt-in para evitar custos inesperados
}

#------------------------------------------------------------------------------
# Configuração Opcional de Security Groups
#------------------------------------------------------------------------------
variable "security_groups" {
  type = map(object({
    description           = string
    disable_default_rules = optional(bool, true)
    rules = list(object({
      description      = string
      direction        = string
      ethertype        = string
      port_range_min   = optional(number)
      port_range_max   = optional(number)
      protocol         = optional(string)
      remote_ip_prefix = optional(string)
    }))
  }))
  description = "A map of Security Groups to be created within the VPC. The map key is used as the SG name."
  default     = {}
}