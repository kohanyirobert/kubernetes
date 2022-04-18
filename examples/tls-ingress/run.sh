domain=app.dev
name=tls-ingress

mkcert $domain
kubectl create secret tls $name --cert=$domain.pem --key=$domain-key.pem
rm $domain.pem
rm $domain-key.pem

kubectl apply -f $(dirname $0)
until kubectl wait pod --all --for=condition=Ready --timeout=0s
do
  echo "warning: resources don't exist"
  sleep 1
done
echo "info: resources exist"
kubectl wait pod --all --for=condition=Ready --timeout=120s

ip=$(kubectl get ingress $name -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl --verbose --resolve $domain:443:$ip https://$domain

kubectl delete secret $name

kubectl delete -f $(dirname $0)
kubectl wait pod --all --for=delete
