# Simple test to check basic stuff works
kubectl apply -f $(dirname $0)
until kubectl wait pod --all --for=condition=Ready --timeout=0s
do
  echo "warning: resources don't exist"
  sleep 1
done
echo "info: resources exist"
kubectl wait pod --all --for=condition=Ready --timeout=120s

node_port=$(kubectl get service smoke-test -o=jsonpath={.spec.ports[*].nodePort})
for char in a b c
do
  for _ in $(seq 10)
  do
    curl node-$char:$node_port
    sleep 1
  done
done

kubectl delete -f $(dirname $0)
kubectl wait pod --all --for=delete
