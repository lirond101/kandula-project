# Cleanup
kubectl delete -f apache-app.yaml
kubectl delete -f jenkins-app.yaml
kubectl delete ingress --all
kubectl delete ingress devtools-ingress -n jenkins
kubectl delete ingress ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
kubectl delete namespace jenkins
kubectl delete namespace check