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
  cloud {
    organization = "opsschool-lirondadon"
    workspaces {
      name = "Kandula-EKS"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.aws_region
}

# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

# TODO move cluster_name into s3 bucket or on the host disk.
data "aws_eks_cluster" "eks" {
  depends_on = [module.eks.cluster_id]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [module.eks.cluster_id]
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}