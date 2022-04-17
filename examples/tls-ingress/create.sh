mkcert app.dev
kubectl create secret tls tls-ingress --cert=app.dev.pem --key=app.dev-key.pem
rm app.dev.pem
rm app.dev-key.pem

kubectl apply -f $(dirname $0)
until kubectl wait pod --all --for=condition=Ready --timeout=0s
do
  echo "warning: resources don't exist"
  sleep 1
done
echo "info: resources exist"
kubectl wait pod --all --for=condition=Ready --timeout=120s

# After this curl https://app.dev works if /etc/hosts contains the ingress's IP with the app.dev domain.
