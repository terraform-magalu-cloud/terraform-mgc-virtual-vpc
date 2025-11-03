variable "region" {
  type        = string
  description = "A região da Magalu Cloud onde a infraestrutura será provisionada."
  default     = "br-se1"
}

variable "api_key" {
  description = "A chave de API da Magalu Cloud."
  type        = string
  sensitive   = true
  default     = ""  
}

variable "bastion_host_ip" {
  type        = string
  description = "O endereço IP do Bastion Host ou da rede corporativa para acesso SSH."
  # Em um cenário real, este valor não teria um default e seria fornecido via .tfvars ou pipeline.
  default     = "203.0.113.5/32"
}