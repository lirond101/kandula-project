# Cleanup
kubectl delete ingress kandula-ingress -n kandula
kubectl delete ingress jenkins-ingress -n jenkins
kubectl delete ingress consul-ingress -n consul
kubectl delete ingress monitoring-ingress

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml

kubectl delete -f kandula-app.yaml
kubectl delete -f jenkins-app.yaml

kubectl delete namespace jenkins
kubectl delete namespace kandula

helm -n consul uninstall consul
kubectl delete ns consul

# helm uninstall prometheus -n prometheus
helm uninstall prometheus
kubectl delete ns prometheus