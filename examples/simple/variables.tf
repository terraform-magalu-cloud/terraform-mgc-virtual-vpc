variable "region" {
  description = "Região da Magalu Cloud onde os recursos serão provisionados."
  type        = string
  default     = "br-ne1"
}

variable "api_key" {
  description = "Chave de API da Magalu Cloud. Pode ser definida via variável de ambiente MGC_API_KEY."
  type        = string
  sensitive   = true
  default     = "dummy-api-key-for-validation"
}

variable "name" {
  description = "Nome base para a VPC."
  type        = string
  default     = "simple-vpc"
}
