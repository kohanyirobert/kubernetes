# CodeDNS pods are likely to all run on the first control-plane node.
# Rebalance them after all worked nodes joined the cluster.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#:~:text=Note%3A%20As%20the,node%20is%20joined.
number_of_unique_nodes=$(kubectl get pods \
  --namespace kube-system \
  --selector k8s-app=kube-dns \
  -o go-template="{{range .items}}{{.spec.nodeName}}{{println}}{{end}}" \
  | wc --lines)

if [ $number_of_unique_nodes -le 1 ]
then
  kubectl \
    --namespace kube-system \
    rollout \
    restart \
    deployment \
    coredns
fi

