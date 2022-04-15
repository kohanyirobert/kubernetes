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

if ! grep --quiet '\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.local"\]' /etc/containerd/config.toml
then
  cat > /tmp/a << EOF
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.local"]
          endpoint = ["http://docker.local"]
EOF
  sudo sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry.mirrors\]/r /tmp/a' /etc/containerd/config.toml
  rm -rf /tmp/a
fi

if ! grep --quiet '\[plugins."io.containerd.grpc.v1.cri".registry.configs."docker.local".tls\]' /etc/containerd/config.toml
then
  cat > /tmp/a << EOF
        [plugins."io.containerd.grpc.v1.cri".registry.configs."docker.local".tls]
          insecure_skip_verify = true
EOF
  sudo sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry.configs\]/r /tmp/a' /etc/containerd/config.toml
  rm -rf /tmp/a
fi

sudo systemctl restart containerd
