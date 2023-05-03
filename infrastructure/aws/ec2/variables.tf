
variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
}

variable "env_name" {
  type        = string
  description = "Name of environment it run on"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "opsschool"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "key_name" {
  type        = string
  description = "key variable for refrencing"
  default     = "kandulaKey"
}

variable "ssh_base_path" {
  type        = string
  description = "Base path for referencing ssh files"
  default     = "/home/ec2-user/.ssh"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
}

variable "public_subnets" {
  type = list(string)
  description = "Desired public_subnets as list of strings"
}

variable "private_subnets" {
  type = list(string)
  description = "Desired private_subnets as list of strings"
}

variable "availability_zone" {
  type = list(string)
  description = "Desired AZs as list of strings"
}

variable "s3_bucket_name" {
  type = string
  description = "Name of the S3 bucket to create"
  default = "kandula9-lirondadon"
}

variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}

variable "ubuntu_18_region_based_ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
  }
}

variable "instance_count_consul_servers" {
  default = 3
  description = "Number of Consul servers"
}

variable "bastion_allowed_cidr_blocks" {
  type = list
  description = "Allow these cidr blocks, seperated by comma"
}