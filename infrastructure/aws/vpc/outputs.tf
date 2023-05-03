# output "aws_alb_public_dns" {
#   value = aws_lb.alb.dns_name
# }

output "vpc_id" {
    value = "${module.my_vpc.vpc_id}"
}

output "vpc_cidr_block" {
    value = "${module.my_vpc.vpc_cidr_block}"
}

# output "bastion_servers" {
#   value = "${module.my_ec2.bastion_servers}"
# }

# output "consul_servers" {
#   value = "${module.my_ec2.consul_servers}"
# }

# output "aws_consul_ids" {
#   value = "${module.my_ec2.aws_consul_ids}"
# }