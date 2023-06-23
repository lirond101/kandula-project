# Cleanup
kubectl delete ingress kandula-ingress -n kandula
kubectl delete ingress jenkins-ingress -n jenkins

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml

kubectl delete -f kandula-app.yaml
kubectl delete -f jenkins-app.yaml

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

sed -i "s/$INGRESS_LB_CNAME/google.com/" route_53_change_batch.json