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

calicoctl_version=${calico_version}.2
calicoctl_os=linux
calicoctl_platform=amd64
calicoctl_binary=calicoctl-$calicoctl_os-$calicoctl_platform
calicoctl_url=https://github.com/projectcalico/calico/releases/download/v$calicoctl_version/$calicoctl_binary
wget --no-verbose --timestamping $calicoctl_url
sudo install \
  --verbose \
  --mode=+x $calicoctl_binary /usr/local/bin/calicoctl
