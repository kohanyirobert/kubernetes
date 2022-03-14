if [ ! -f $HOME/.kube/config ]
then
  sudo kubeadm init \
    --apiserver-advertise-address=$1 \
    --pod-network-cidr=192.168.0.0/16

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
fi

calico_version=3.22
if ! kubectl wait pod --all --for=condition=Ready --namespace tigera-operator --timeout=0s
then
  kubectl create -f https://projectcalico.docs.tigera.io/archive/v$calico_version/manifests/tigera-operator.yaml
  until kubectl wait pod --all --for=condition=Ready --namespace tigera-operator
  do
    echo "warning: resources don't exist yet in namespace tigera-operator"
    sleep 1
  done
  kubectl wait pod --all --for=condition=Ready --namespace tigera-operator --timeout=120s
fi

if ! kubectl wait pod --all --for=condition=Ready --namespace calico-system --timeout=0s
then
  kubectl create -f https://projectcalico.docs.tigera.io/archive/v$calico_version/manifests/custom-resources.yaml
  until kubectl wait pod --all --for=condition=Ready --namespace calico-system
  do
    echo "warning: resources don't exist yet in namespace calico-system"
    sleep 1
  done
  kubectl wait pod --all --for=condition=Ready --namespace calico-system --timeout=120s
fi
