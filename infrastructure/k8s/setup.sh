# echo "### Update kubeconfig with cluster name $1"
aws eks --region=$2 update-kubeconfig --name $1

# echo "### Add employee2 to configmap 'aws-auth'"
eksctl get iamidentitymapping --cluster $1 --region=$2
# eksctl create iamidentitymapping \
#     --cluster $1 \
#     --region=$2 \
#     --arn arn:aws:iam::902770729603:user/employee2 \
#     --group system:masters \
#     --no-duplicate-arns

echo "### Add Role AdministratorAccess to configmap 'aws-auth'"
eksctl create iamidentitymapping --cluster  $1 --region=$2 --arn arn:aws:iam::902770729603:role/AdministratorAccess --group system:masters --username admin
eksctl get iamidentitymapping --cluster $1 --region=$2

# Install NGINX ingress conroller 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Install Jenkins
kubectl create namespace jenkins
kubectl apply -f jenkins-cluster-sa.yaml
kubectl apply -f jenkins-sa-secret.yaml
kubectl apply -f jenkins-pv-claim.yaml
kubectl apply -f jenkins-app.yaml
kubectl apply -f jenkins-ingress.yaml
sleep 120

# Moved into jenkins jobs
# kubectl apply -f kandula-app.yaml
# kubectl apply -f kandula-ingress.yaml

INGRESS_LB_CNAME=$(kubectl get ingress jenkins-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" -n jenkins)
echo $INGRESS_LB_CNAME
kubectl -n jenkins describe secrets sa-jenkins