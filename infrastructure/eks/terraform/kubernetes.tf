# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_service_account" "opsschool_sa" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_iam-assumable-role-with-oidc.iam_role_arn
    }
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "jenkins_namespace" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_secret" "sa_secret" {
  metadata {
    name = "sa-secret"
  }
}

resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-admin"
    namespace = "${kubernetes_namespace.jenkins_namespace.metadata.0.name}"
  }
  secret {
    name = "${kubernetes_secret.sa_secret.metadata.0.name}"
  }
  depends_on = [module.eks]
}