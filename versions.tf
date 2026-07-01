terraform {
  required_version = ">= 1.6.0"
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = ">= 0.52.0"
    }
  }
}

provider "mgc" {
  region  = "br-se1"
  api_key = var.api_key
}

variable "api_key" {
  description = "The API key for the MGC provider"
  type        = string
}