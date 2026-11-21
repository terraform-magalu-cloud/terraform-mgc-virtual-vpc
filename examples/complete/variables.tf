variable "region" {
  description = "Regiao da Magalu Cloud onde os recursos serao provisionados."
  type        = string
  default     = "br-ne1"
}

variable "api_key" {
  description = "Chave de API da Magalu Cloud. Pode ser definida via variavel de ambiente MGC_API_KEY."
  type        = string
  sensitive   = true
  default     = "dummy-api-key-for-validation"
}

variable "name" {
  description = "Nome base para a VPC e seus recursos associados."
  type        = string
  default     = "prod-vpc"
}

variable "route_appliance_port_id" {
  description = "UUID da porta ou interface de rede para rota customizada (opcional). Deixe null para nao criar rota por padrao."
  type        = string
  default     = null
}
