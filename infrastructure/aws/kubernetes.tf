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

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

resource "kubernetes_namespace" "kandula_namespace" {
  metadata {
    name = "kandula"
  }
}

resource "kubernetes_deployment" "kandula_deployment" {
  metadata {
    name = "kandula-app"
    namespace = "kandula"
    labels = {
      app = "kandula-app"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kandula-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "kandula-app"
        }
      }
      spec {
        service_account_name = "opsschool-sa"

        container {
          image = "lirondadon/kandula:latest"
          name  = "kandula"

          port {
            container_port = 5000
            name = "http"
            protocol = "TCP"
          }
          env {
            name = "FLASK_DEBUG"
            value = "1"
          }
          env {
            name = "AWS_DEFAULT_REGION"
            value = "us-east-2"
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 90
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kandula-svc" {
  metadata {
    name = "kandula-svc"
    namespace = "kandula"
  }
  spec {
    selector = {
      app = "kandula-app"
    }
    port {
      port        = 5000
      target_port = 5000
      protocol = "TCP"
    }
    type = "ClusterIP"
  }
}
