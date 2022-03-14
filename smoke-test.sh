kubectl create deployment --image=traefik/whoami --port=80 --replicas=2 whoami
until kubectl wait pod --all --for=condition=Ready
do
  echo "warning: resources don't exist yet in the default namespace"
  sleep 1
done
kubectl wait pod --all --for=condition=Ready --timeout=120s

kubectl expose deployment whoami --type=NodePort
until kubectl get service whoami
do
  echo "warning: resource doesn't exist yet in the default namespace"
  sleep 1
done

node_port=$(kubectl get service whoami -o=jsonpath={.spec.ports[*].nodePort})
for char in a b c
do
  for _ in $(seq 10)
  do
    curl node-$char:$node_port
    sleep 1
  done
done

kubectl delete service whoami
kubectl wait service whoami --for=delete --timeout=120s
kubectl delete deployment whoami
kubectl wait deployment whoami --for=delete --timeout=120s
