export AWS_PROFILE=employee2
CALLER_IDENTITY=$(aws sts get-caller-identity)
echo $CALLER_IDENTITY
cd ~/kandula-project/infrastructure/k8s

# KUBECONFIG
#TODO add with terraform another role to interact with cluster
echo "### Update kubeconfig with cluster name $1"
aws eks --region=$2 update-kubeconfig --name $1

# IAM
echo "### Get IAM Idneitity mapping from aws-auth"
eksctl get iamidentitymapping --cluster $1 --region=$2
echo "### Add Roles into configmap 'aws-auth'"
eksctl create iamidentitymapping --cluster  $1 --region=$2 --arn arn:aws:iam::902770729603:role/AdministratorAccess --group system:masters --username admin
eksctl create iamidentitymapping --cluster  $1 --region=$2 --arn arn:aws:iam::902770729603:role/allow_describe_ec2 --group system:masters --username dev1
eksctl get iamidentitymapping --cluster $1 --region=$2
# In case of error use the same user/role that created the cluster.
# echo "### Add employee2 to configmap 'aws-auth'"
# eksctl create iamidentitymapping \
#     --cluster $1 \
#     --region=$2 \
#     --arn arn:aws:iam::902770729603:user/employee2 \
#     --group system:masters \
#     --no-duplicate-arns

# CONSUL
#TODO change key to a generated one (https://github.com/hashicorp/terraform-provider-consul/issues/48)
kubectl create ns consul
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg==" -n consul
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install --values consul/helm/values.yaml consul hashicorp/consul --namespace consul --version "1.1.0"

# NGINX INGRESS CONTROLLER
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml
sleep 30
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# JENKINS
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
echo "INGRESS_LB_CNAME = $INGRESS_LB_CNAME"
kubectl -n jenkins describe secrets sa-jenkins

kubectl apply -f consul-ingress.yaml

echo "### Add Consul dns to configmap 'coredns'"
CONSUL_DNS=$(kubectl get svc consul-dns -n consul -o jsonpath="{.spec.clusterIP}")
echo "CONSUL_DNS = $CONSUL_DNS"

#TODO update here route_53_change_batch.json with jq eith the values of INGRESS_LB_CNAME and the record
sed -i "s/google.com/$INGRESS_LB_CNAME/" route_53_change_batch.json
aws route53 change-resource-record-sets --hosted-zone-id Z01928206842WG4H1R0U --change-batch file://route_53_change_batch.json

sed "s/x.x.x.x/$CONSUL_DNS/" consul/corefile.json | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --create-namespace --namespace monitoring

helm repo add elastic https://Helm.elastic.co
kubectl create ns elastic
helm install elasticsearch elastic/elasticsearch --values elk/elasticsearch/values.yaml --namespace elastic --version "7.17.3"
helm install filebeat elastic/filebeat --values elk/filebeat/values.yaml --namespace elastic --version "7.17.3"
helm install kibana elastic/kibana --values elk/kibana/values.yaml --namespace elastic --version "7.17.3"