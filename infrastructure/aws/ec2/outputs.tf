# output "aws_alb_public_dns" {
#   value = aws_lb.alb.dns_name
# }

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "vpc_id" {
    value = "${module.my_vpc.vpc_id}"
}

output "vpc_cidr_block" {
    value = "${module.my_vpc.vpc_cidr_block}"
}

output "bastion_servers" {
  value = "${module.my_ec2.bastion_servers}"
}

# output "consul_servers" {
#   value = "${module.my_ec2.consul_servers}"
# }

# output "aws_consul_ids" {
#   value = "${module.my_ec2.aws_consul_ids}"
# }