echo "### Update kubeconfig with cluster name $1"
aws eks --region=us-east-1 update-kubeconfig --name $1

echo "### Add employee2 to configmap 'aws-auth'"
eksctl get iamidentitymapping --cluster $1 --region=us-east-1
eksctl create iamidentitymapping \
    --cluster $1 \
    --region=us-east-1 \
    --arn arn:aws:iam::902770729603:user/employee2 \
    --group system:masters \
    --no-duplicate-arns
eksctl get iamidentitymapping --cluster $1 --region=us-east-1

# Install NGINX ingress conroller 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Configure ebs-csi and iam role for it
eksctl create addon --name aws-ebs-csi-driver --cluster $1 --service-account-role-arn arn:aws:iam::902770729603:role/AmazonEKS_EBS_CSI_DriverRole --force
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole

# Create jenkins and apache appications
kubectl apply -f jenkins-sa.yaml
kubectl apply -f jenkins-pv-claim.yaml
kubectl apply -f jenkins-app.yaml

kubectl create namespace kandula
kubectl apply -f kuar-app.yaml
kubectl apply -f kuar-ingress.yaml
kubectl apply -f devtools-ingress.yaml
sleep 120

INGRESS_LB_CNAME=$(kubectl get ingress kuar-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" -n kandula)
echo $INGRESS_LB_CNAME