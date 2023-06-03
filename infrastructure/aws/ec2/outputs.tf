# output "aws_alb_public_dns" {
#   value = aws_lb.alb.dns_name
# }

output "bastion_servers" {
  value = "${module.my_ec2.bastion_servers}"
}

output "db_servers" {
  value = "${module.my_ec2.db_servers}"
}

output "aws_db_ids" {
  value = "${module.my_ec2.aws_db_ids}"
}