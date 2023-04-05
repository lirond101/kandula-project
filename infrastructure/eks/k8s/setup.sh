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

# # Install NGINX ingress conroller 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Create jenkins and apache appications
kubectl apply -f jenkins-app.yaml
kubectl apply -f jenkins-sa.yaml

kubectl create namespace kandula
kubectl apply -f kuar-app.yaml
kubectl apply -f kuar-ingress.yaml
kubectl apply -f devtools-ingress.yaml
sleep 120

INGRESS_LB_CNAME=$(kubectl get ingress kuar-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" -n kandula)
echo $INGRESS_LB_CNAME