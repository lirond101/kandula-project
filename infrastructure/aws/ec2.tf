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

# INSTANCES #
module "my_ec2" {
    depends_on = [
    module.my_vpc,
    aws_iam_instance_profile.instance_profile
  ]
  source                             = "./modules/ec2"
  
  # vpc
  vpc_id                             = module.my_vpc.vpc_id
  vpc_cidr_block                     = module.my_vpc.vpc_cidr_block
  vpc_public_subnets                 = module.my_vpc.vpc_public_subnets
  vpc_private_subnets                = module.my_vpc.vpc_private_subnets

  # bastion
  instance_count_bastion             = length(var.public_subnets)
  ami_bastion                        = nonsensitive(data.aws_ssm_parameter.ami.value)
  bastion_allowed_cidr_blocks        = ["79.182.179.3/32"]

  # consul
  instance_count_consul             = 6
  ami_consul                        = data.aws_ami.ubuntu-18.id
  iam_instance_profile_consul       = aws_iam_instance_profile.instance_profile.name
  key_name                         = var.key_name
  user_data_consul                  = templatefile("${path.module}/startup_script.tpl", {
                                      vpc_cidr_block = module.my_vpc.vpc_cidr_block
                                    })

  name_prefix          = local.name_prefix
  common_tags                      = {}
}