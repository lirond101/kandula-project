# DATA
data "aws_elb_service_account" "root" {}

# ALB
resource "aws_lb" "alb" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = keys(module.my_vpc.vpc_public_subnets)[*]
  enable_deletion_protection = false

  tags = local.common_tags
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "${local.name_prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_vpc.vpc_id

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }

  stickiness {
    cookie_duration = "60"
    type = "lb_cookie"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = local.common_tags
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  depends_on = [
    module.my_ec2,
  ]
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = module.my_ec2.aws_nginx_id[count.index]
  port             = 80
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  depends_on = [
    module.my_vpc,
  ]
  name   = "${local.name_prefix}-nginx_alb_sg"
  vpc_id = module.my_vpc.vpc_id
  tags = local.common_tags
}

resource "aws_security_group_rule" "allow_http" {
 type              = "ingress"
 description       = "HTTP ingress"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_allow_all_outbound" {
 type              = "egress"
 description       = "outbound internet access"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.alb_sg.id
}