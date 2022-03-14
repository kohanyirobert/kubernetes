sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

kubernetes_version=1.23.4*
sudo apt-get update
sudo apt-get install -y \
  kubelet=$kubernetes_version \
  kubeadm=$kubernetes_version \
  kubectl=$kubernetes_version
sudo apt-mark hold \
  kubelet=$kubernetes_version \
  kubeadm=$kubernetes_version \
  kubectl=$kubernetes_version
