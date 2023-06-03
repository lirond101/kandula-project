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
  version = "1.0.6"
  
  # VPC
  vpc_id                       = data.aws_vpc.selected.id
  vpc_cidr_block               = var.vpc_cidr_block
  vpc_public_subnets           = data.aws_subnets.public.ids
  vpc_private_subnets          = data.aws_subnets.private.ids

  #EC2
  key_name                     = var.key_name

  # BASTION
  # instance_count_bastion             = length(var.public_subnets)
  instance_count_bastion       = 1
  ami_bastion                  = nonsensitive(data.aws_ssm_parameter.ami.value)
  bastion_allowed_cidr_blocks  = var.bastion_allowed_cidr_blocks

  # DB
  # instance_count_db             = var.instance_count_db
  instance_count_db           = 1
  ami_db                      = data.aws_ami.ubuntu-18.id
  iam_instance_profile_db     = aws_iam_instance_profile.instance_profile.name

  name_prefix                 = local.name_prefix
  common_tags                 = merge(local.common_tags, {
    consul_server = "true"
  }) 
}