# DATA
data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_vpc" "selected" {
  cidr_block = var.vpc_cidr_block
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier = "Public"
  }
}

# INSTANCES #
module "my_ec2" {
    depends_on = [
    aws_iam_instance_profile.instance_profile
  ]
  source  = "app.terraform.io/opsschool-lirondadon/ec2/aws"
  version = "1.0.2"
  
  # VPC
  vpc_id                             = data.aws_vpc.selected.id
  vpc_cidr_block                     = var.vpc_cidr_block
  vpc_public_subnets                 = data.aws_subnets.public.ids
  vpc_private_subnets                = data.aws_subnets.private.ids

  # BASTION
  instance_count_bastion             = length(var.public_subnets)
  ami_bastion                        = nonsensitive(data.aws_ssm_parameter.ami.value)
  bastion_allowed_cidr_blocks        = var.bastion_allowed_cidr_blocks
  key_name                           = var.key_name



  # CONSUL
  instance_count_consul             = 0
  # instance_count_consul             = var.instance_count_consul_servers
  ami_consul                        = lookup(var.ubuntu_18_region_based_ami, var.aws_region)
  iam_instance_profile_consul       = aws_iam_instance_profile.instance_profile.name
  # key_name                          = var.key_name
  # user_data_consul                = file("${path.module}/scripts/consul-server.sh")

  name_prefix                       = local.name_prefix
  common_tags                       = local.common_tags
}