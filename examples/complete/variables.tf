variable "api_key" {
  description = "The API key for the MGC provider"
  type        = string
}

variable "external_port_id" {
  description = "An existing port ID to use for the outbound route next hop"
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "internal_port_id" {
  description = "An existing port ID to use for the internal peering route next hop"
  type        = string
  default     = "00000000-0000-0000-0000-000000000002"
}