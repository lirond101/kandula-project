cd ~/kandula-project/infrastructure/k8s
#TODO add with terraform another role to interact with cluster
# echo "### Update kubeconfig with cluster name $1"
aws eks --region=$2 update-kubeconfig --name $1

# In case of error use the same user/role that created the cluster.
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

#TODO change key to a generated one (https://github.com/hashicorp/terraform-provider-consul/issues/48)

kubectl create ns consul
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg==" -n consul
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install --values helm/values-v10.yaml consul hashicorp/consul --namespace consul --version "1.0.2"

# Install NGINX ingress conroller 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml
sleep 10
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

echo "### Add Consul dns to configmap 'coredns'"
CONSUL_DNS=$(kubectl get svc consul-dns -n consul -o jsonpath="{.spec.clusterIP}")
sed "s/x.x.x.x/$CONSUL_DNS/" corefile.json | kubectl apply -f -