echo "### Update kubeconfig with cluster name $1"
aws eks --region=us-east-1 update-kubeconfig --name $1

echo "### Add employee2 to configmap 'aws-auth'"
eksctl get iamidentitymapping --cluster $1 --region=us-east-1
eksctl create iamidentitymapping \
    --cluster $1 \
    --region=us-east-1 \
    --arn arn:aws:iam::$2:user/$3 \
    --group system:masters \
    --no-duplicate-arns
eksctl get iamidentitymapping --cluster $1 --region=us-east-1