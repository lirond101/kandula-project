##################################################################################
# TERRAFORM CONFIG
##################################################################################

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.18.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 1.1.0"
  # cloud {
  #   organization = "opsschool-lirondadon"
  #   workspaces {
  #     name = "Kandula"
  #   }
  # }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
}