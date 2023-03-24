##################################################################################
# TERRAFORM CONFIG
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.0"
  # cloud {
  #   organization = "opsschool-lirondadon"
  #   workspaces {
  #     name = "AWS-and-Terraform"
  #   }
  # }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
}