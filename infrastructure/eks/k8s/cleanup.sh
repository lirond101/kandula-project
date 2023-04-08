# Cleanup
eksctl delete addon --cluster $1 --name aws-ebs-csi-driver --preserve
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml

kubectl delete -f kuar-app.yaml
kubectl delete -f jenkins-app.yaml

kubectl delete ingress kuar-ingress -n kandula
kubectl delete ingress devtools-ingress -n jenkins

kubectl delete namespace jenkins
kubectl delete namespace kandula