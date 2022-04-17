kubectl delete secret tls-ingress

kubectl delete -f $(dirname $0)
kubectl wait pod --all --for=delete
