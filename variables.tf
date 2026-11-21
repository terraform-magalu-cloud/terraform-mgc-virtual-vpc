variable "create" {
  description = "Defines whether resources in this module will be created."
  default     = true
  type        = bool
}

variable "name" {
  description = "The name of the VPC."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The VPC name cannot be empty."
  }
}

variable "description" {
  description = "The description of the VPC. Must only contain letters (A-Z, a-z), numbers (0-9), spaces, and hyphens (-)."
  default     = null
  type        = string

  validation {
    condition     = var.description == null || can(regex("^[a-zA-Z0-9 -]*$", var.description))
    error_message = "The description must only contain letters (A-Z, a-z), numbers (0-9), spaces, and hyphens (-)."
  }
}

variable "create_subnetpool" {
  description = "Defines whether a dedicated Subnet Pool should be created for this VPC."
  default     = true
  type        = bool
}

variable "subnetpool_name" {
  description = "The name of the Subnet Pool. If null and create_subnetpool is true, defaults to '<name>-subnetpool'."
  default     = null
  type        = string
}

variable "subnetpool_description" {
  description = "The description of the Subnet Pool. If null and create_subnetpool is true, defaults to 'Subnet pool for <name>'."
  default     = null
  type        = string
}

variable "subnetpool_cidr" {
  description = "The CIDR block of the Subnet Pool."
  default     = "10.0.0.0/16"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnetpool_cidr))
    error_message = "The subnetpool_cidr must be a valid IPv4 CIDR block (e.g. '10.0.0.0/16')."
  }
}

variable "subnetpool_id" {
  description = "An existing Subnet Pool ID to use when create_subnetpool is false."
  default     = null
  type        = string
}

variable "use_default_subnetpool" {
  description = "Whether to look up and use the tenant's default Subnet Pool if create_subnetpool is false and subnetpool_id is null."
  default     = false
  type        = bool
}

variable "default_dns_nameservers" {
  description = "Default DNS nameservers for subnets if not specified individually."
  default     = ["8.8.8.8", "8.8.4.4"]
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create within the VPC. Key is used as subnet identifier."
  type = map(object({
    name              = optional(string)
    cidr_block        = string
    ip_version        = optional(string, "IPv4")
    availability_zone = optional(string)
    description       = optional(string)
    dns_nameservers   = optional(list(string))
    subnetpool_id     = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, s in var.subnets : contains(["IPv4", "IPv6"], coalesce(s.ip_version, "IPv4"))
    ])
    error_message = "Every subnet must have ip_version set to either 'IPv4' or 'IPv6'."
  }

  validation {
    condition = alltrue([
      for k, s in var.subnets : can(cidrnetmask(s.cidr_block)) || can(cidrhost(s.cidr_block, 0))
    ])
    error_message = "Every subnet must have a valid CIDR block."
  }
}

variable "enable_nat_gateway" {
  description = "Defines whether to create a default NAT Gateway for the VPC."
  default     = false
  type        = bool
}

variable "nat_gateway_name" {
  description = "Name of the default NAT Gateway. If null and enable_nat_gateway is true, defaults to '<name>-nat-gateway'."
  default     = null
  type        = string
}

variable "nat_gateway_description" {
  description = "Description of the default NAT Gateway."
  default     = null
  type        = string
}

variable "nat_gateway_zone" {
  description = "Availability zone for the default NAT Gateway (e.g. 'br-ne1-a'). If null, falls back to the availability zone of the first configured subnet."
  default     = null
  type        = string
}

variable "nat_gateways" {
  description = "Map of NAT Gateways to create within the VPC. If provided, takes precedence over enable_nat_gateway single gateway creation."
  type = map(object({
    name              = optional(string)
    description       = optional(string)
    availability_zone = optional(string)
  }))
  default = {}
}

variable "security_groups" {
  description = "Map of security groups and their associated rules to create in the VPC."
  type = map(object({
    name                  = optional(string)
    description           = optional(string)
    disable_default_rules = optional(bool, false)
    rules = optional(map(object({
      description      = optional(string)
      direction        = string
      ethertype        = optional(string, "IPv4")
      port_range_min   = optional(number)
      port_range_max   = optional(number)
      protocol         = optional(string, "tcp")
      remote_ip_prefix = optional(string, "0.0.0.0/0")
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for sg_k, sg in var.security_groups : [
        for r_k, r in coalesce(sg.rules, {}) : contains(["ingress", "egress"], r.direction)
      ]
    ]))
    error_message = "Each security group rule direction must be either 'ingress' or 'egress'."
  }
}

variable "routes" {
  description = "Map of custom routes to add to the VPC route table (e.g. for VPC peering or network ports)."
  type = map(object({
    cidr_destination = string
    description      = optional(string)
    peering_id       = optional(string)
    port_id          = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, r in var.routes : (
        (r.port_id != null && r.peering_id == null) ||
        (r.port_id == null && r.peering_id != null)
      )
    ])
    error_message = "Every route must define exactly one of 'port_id' or 'peering_id'."
  }

  validation {
    condition = alltrue([
      for k, r in var.routes : (
        (r.port_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", r.port_id))) &&
        (r.peering_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", r.peering_id)))
      )
    ])
    error_message = "Route 'port_id' or 'peering_id' must be a valid UUID (e.g. '00000000-0000-0000-0000-000000000000')."
  }
}

variable "public_ips" {
  description = "Map of public IPs to allocate for this VPC."
  type = map(object({
    description = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Optional map of tags to attach to the VPC resource."
  type        = map(string)
  default     = {}
}
