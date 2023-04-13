# # DATA
# data "aws_ami" "ubuntu-18" {
#   most_recent = true
#   owners      = [var.ubuntu_account_number]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }
# }

# data "aws_ssm_parameter" "ami" {
#   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
# }

# # INSTANCES #
# module "my_ec2" {
#     depends_on = [
#     module.my_vpc,
#     aws_iam_instance_profile.instance_profile
#   ]
#   source                             = "./modules/ec2"
  
#   # vpc
#   vpc_id                             = module.my_vpc.vpc_id
#   vpc_cidr_block                     = module.my_vpc.vpc_cidr_block
#   vpc_public_subnets                 = module.my_vpc.vpc_public_subnets
#   vpc_private_subnets                = module.my_vpc.vpc_private_subnets

#   # bastion
#   ami_bastion                        = nonsensitive(data.aws_ssm_parameter.ami.value)
#   instance_type_bastion              = var.instance_type
#   bastion_allowed_cidr_blocks        = ["79.182.181.105/32"]

#   # nginx
#   instance_count_nginx             = var.instance_count
#   ami_nginx                        = data.aws_ami.ubuntu-18.id
#   instance_type_nginx              = var.instance_type
#   iam_instance_profile_nginx       = aws_iam_instance_profile.instance_profile.name
#   encrypted_disk_device_name_nginx = var.nginx_encrypted_disk_device_name
#   key_name                         = var.key_name
#   user_data_nginx                  = templatefile("${path.module}/startup_script.tpl", {
#                                       vpc_cidr_block = module.my_vpc.vpc_cidr_block
#                                     })
#   # db
#   instance_count_db                = var.instance_count
#   ami_db                           = data.aws_ami.ubuntu-18.id
#   instance_type_db                 = var.instance_type



#   naming_prefix                    = "kandula"
#   common_tags                      = merge(local.common_tags, {
#                                       Name = "${local.name_prefix}-ec2",
#                                       Version = "v1.0.0"
#                                     })
# }