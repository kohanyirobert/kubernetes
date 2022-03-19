# Installs Calico CNI using Tigera operators for networking between nodes
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
calico_version=3.22
if ! kubectl wait pod --all --for=condition=Ready --namespace tigera-operator --timeout=0s
then
  kubectl apply -f https://projectcalico.docs.tigera.io/archive/v$calico_version/manifests/tigera-operator.yaml
  until kubectl wait pod --all --for=condition=Ready --namespace tigera-operator
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace tigera-operator --timeout=120s
fi

if ! kubectl wait pod --all --for=condition=Ready --namespace calico-system --timeout=0s
then
  kubectl apply -f https://projectcalico.docs.tigera.io/archive/v$calico_version/manifests/custom-resources.yaml
  until kubectl wait pod --all --for=condition=Ready --namespace calico-system
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace calico-system --timeout=120s
fi
