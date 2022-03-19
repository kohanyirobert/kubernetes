# Makes a node join a cluster as a worker (executed from a control-plane node)
if ! kubectl wait node $1 --for=condition=Ready --timeout=0s
then
  ssh -o StrictHostKeyChecking=no vagrant@$1 -- sudo $(kubeadm token create --print-join-command)
  until kubectl wait node $1 --for=condition=Ready
  do
    echo "warning: node doesn't exist yet"
    sleep 1
  done
  kubectl wait node $1 --for=condition=Ready --timeout=120s
fi
