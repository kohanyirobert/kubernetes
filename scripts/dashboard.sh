dashboard_version=2.5.1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v$dashboard_version/aio/deploy/recommended.yaml

until kubectl wait pod --all --for=condition=available --namespace= kubernetes-dashboard --timeout=0s
do
  echo "warning: resources don't exist"
  sleep 1
done
echo "info: resources exist"
kubectl wait pod --all --for=condition=available --namespace= kubernetes-dashboard --timeout=120s
