module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.10.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = keys(module.my_vpc.vpc_private_subnets)

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access = true
  
  enable_irsa = true
  
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.my_vpc.vpc_id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 0
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 0
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}
