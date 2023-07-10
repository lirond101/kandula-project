# Cleanup

INGRESS_LB_CNAME=$(kubectl get ingress jenkins-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" -n jenkins)
sed -i "s/$INGRESS_LB_CNAME/google.com/" route_53_change_batch.json

kubectl delete ingress kandula-ingress -n kandula
kubectl delete ingress jenkins-ingress -n jenkins

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml

kubectl delete -f kandula/kandula-app.yaml
kubectl delete -f jenkins/jenkins-app.yaml

kubectl delete namespace jenkins
kubectl delete namespace kandula

helm -n consul uninstall consul
kubectl delete ns consul

helm uninstall prometheus -n monitoring
kubectl delete ns monitoring

helm uninstall kibana -n elastic
helm uninstall elasticsearch -n elastic
helm uninstall filebeat -n elastic
kubectl delete ns elastic

helm uninstall cert-manager -n cert-manager