#!/bin/bash
AWS_REGION="us-east-2"

echo "Destroying kubernetes cluster"
cd ~/kandula-project/infrastructure/k8s/
./cleanup.sh

echo "Destroying terraform eks" 
cd ~/kandula-project/infrastructure/aws/eks/
terraform destroy --auto-approve

echo "Destroying terraform ec2/db" 
cd ~/kandula-project/infrastructure/aws/ec2/
terraform destroy --auto-approve
sed -i "s/$(curl ifconfig.me)/x.x.x.x/" terraform.tfvars

echo "Destroying terraform vpc" 
cd ~/kandula-project/infrastructure/aws/vpc/
terraform destroy --auto-approve


