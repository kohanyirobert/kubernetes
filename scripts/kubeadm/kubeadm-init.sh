# Initializes a control-plane instance on a node including a networking addon
if [ ! -f $HOME/.kube/config ]
then
  sudo kubeadm init \
    --apiserver-advertise-address=$1 \
    --pod-network-cidr=192.168.0.0/16

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  mkdir -p /vagrant/.kube
  cp $HOME/.kube/config /vagrant/.kube/config
fi
