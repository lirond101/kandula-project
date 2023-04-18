# output "aws_nginx_public_dns" {
#   value = aws_instance.nginx.*.private_ip
# }

# output "aws_db_public_dns" {
#   value = aws_instance.db.*.private_ip
# }

# output "aws_nginx_id" {
#   value = aws_instance.nginx.*.id
# }

output "bastion_server" {
  value = aws_instance.bastion.public_ip
}

output "consul_servers" {
  value = aws_instance.consul_server.*.private_ip
}