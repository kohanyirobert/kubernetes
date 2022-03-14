# Installs containerd onto a node without installing Docker or anything related

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# https://containerd.io/docs/getting-started/#systemd-based-distributions
containerd_version=1.6.1
containerd_os=linux
containerd_platform=amd64
containerd_archive=cri-containerd-cni-$containerd_version-$containerd_os-$containerd_platform.tar.gz
containerd_url=https://github.com/containerd/containerd/releases/download/v$containerd_version/$containerd_archive
wget --timestamping $containerd_url

sudo tar --no-overwrite-dir -C / -xzf $containerd_archive
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's,SystemdCgroup = false,SystemdCgroup = true,' /etc/containerd/config.toml

sudo systemctl restart containerd
