#!/bin/bash
AWS_REGION="us-east-2"

echo "Executing terraform vpc" 
cd ~/kandula-project/infrastructure/aws/vpc/
terraform init
terraform apply --auto-approve

echo "Executing terraform ec2/db" 
cd ~/kandula-project/infrastructure/aws/ec2/
sed -i "s/x.x.x.x/$(curl ifconfig.me)/" terraform.tfvars
terraform init
terraform apply --auto-approve

echo "Executing terraform eks" 
cd ~/kandula-project/infrastructure/aws/eks/
terraform init
terraform apply --auto-approve
CLUSTER_NAME=$(terraform output -raw cluster_name)

echo "Provisioning kubernetes cluster $CLUSTER_NAME on $AWS_REGION"
cd ~/kandula-project/infrastructure/k8s/
./setup.sh $CLUSTER_NAME $AWS_REGION

echo "Configuring db" 
cd ~/kandula-project/infrastructure/db/
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-inventory -i db_aws_ec2.yml --graph
ansible-playbook playbook_postgres.yml -i db_aws_ec2.yml
ansible-playbook playbook_clients.yml -i db_aws_ec2.yml


