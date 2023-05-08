resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "${local.name_prefix}-worker-mgt-sg"
#   description = "Security rules for SSH and Consul."
#   vpc_id      = data.aws_vpc.selected.id
#   tags = merge(
#     { "Name" = "${local.name_prefix}-worker-mgt-sg" },
#     { "Environment" = var.env_name }
#   )
# }

# resource "aws_security_group_rule" "nodes_allow_22_bastion" {
#   security_group_id        = aws_security_group.all_worker_mgmt.id
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = 22
#   to_port                  = 22
#   cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
#   description              = "Allow SSH traffic from consul bastion from inside the vpc only."
# }

# resource "aws_security_group_rule" "consul_server_allow_client_8500" {
#   security_group_id        = aws_security_group.all_worker_mgmt.id
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = 8500
#   to_port                  = 8500
#   self                     = true
#   description              = "Allow HTTP traffic from Consul Client."
# }

# resource "aws_security_group_rule" "consul_server_allow_client_8600" {
#   security_group_id        = aws_security_group.all_worker_mgmt.id
#   type                     = "ingress"
#   protocol                 = "udp"
#   from_port                = 8600
#   to_port                  = 8600
#   self                     = true
#   description              = "Allow UDP traffic for DNS queries."
# }

# resource "aws_security_group_rule" "consul_server_allow_client_8301" {
#   security_group_id        = aws_security_group.all_worker_mgmt.id
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = 8301
#   to_port                  = 8301
#   self                     = true
#   description              = "Allow LAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
# }

# resource "aws_security_group_rule" "consul_server_allow_client_8300" {
#   security_group_id        = aws_security_group.all_worker_mgmt.id
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = 8300
#   to_port                  = 8300
#   self                     = true
#   description              = "Allow RPC traffic from Consul Client to Server.  For client and server agents to send and receive data stored in Consul."
# }

# resource "aws_security_group_rule" "consul_server_allow_outbound" {
#   security_group_id = aws_security_group.all_worker_mgmt.id
#   type              = "egress"
#   protocol          = "-1"
#   from_port         = 0
#   to_port           = 0
#   cidr_blocks       = ["0.0.0.0/0"]
#   description       = "Allow any outbound traffic."
# }