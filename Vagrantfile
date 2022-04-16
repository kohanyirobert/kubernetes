class Node
  def initialize(char, control_plane=false)
    @char = char
    @hostname = "node-#{@char}"
    @ip = "172.16.0.#{@char.ord}"
    @netmask = "255.255.0.0"
    @control_plane = control_plane
  end

  def control_plane?
    @control_plane
  end

  attr_reader :char, :hostname, :ip, :netmask
end

control_plane_nodes = [
  Node.new("a", true),
]

worker_nodes = [
  Node.new("b"),
  Node.new("c"),
]

all_nodes = worker_nodes + control_plane_nodes

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20220315.0.0"

  config.vm.provision "shell", name: "multipath.sh", privileged: false, path: "scripts/multipath.sh"
  config.vm.provision "shell", name: "id_rsa.sh", privileged: false, path: "scripts/id_rsa.sh"

  all_nodes.each do |node|
    config.vm.provision "shell",
      name: "hosts.sh (#{node.hostname})",
      privileged: false,
      path: "scripts/hosts.sh",
      args: [node.hostname, node.ip]
  end

  config.vm.provision "shell", name: "containerd.sh", privileged: false, path: "scripts/containerd.sh"
  config.vm.provision "shell", name: "kubeadm/kubeadm.sh", privileged: false, path: "scripts/kubeadm/kubeadm.sh"

  worker_nodes.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip, netmask: node.netmask
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 1024
        vb.linked_clone = true
        vb.customize ["modifyvm", :id, "--vram", 16]
      end
    end
  end

  control_plane_nodes.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip, netmask: node.netmask
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 2048
        vb.linked_clone = true
        vb.customize ["modifyvm", :id, "--vram", 16]
      end
      config.vm.provision "shell", name: "common.sh", privileged: false, path: "scripts/common.sh"
      config.vm.provision "shell",
        name: "kubeadm/kubeadm-init.sh (#{node.hostname})",
        privileged: false,
        path: "scripts/kubeadm/kubeadm-init.sh",
        args: [node.ip]
      config.vm.provision "shell", name: "calico.sh", privileged: false, path: "scripts/calico.sh"
      worker_nodes.map {|n| n.hostname}.each do |hostname|
        config.vm.provision "shell",
          name: "kubeadm/kubeadm-join.sh (#{node.hostname} -> #{hostname})",
          privileged: false,
          path: "scripts/kubeadm/kubeadm-join.sh",
          args: [hostname]
      end
      config.vm.provision "shell", name: "metallb.sh", privileged: false, path: "scripts/metallb.sh"
      config.vm.provision "shell", name: "helm.sh", privileged: false, path: "scripts/helm.sh"
      config.vm.provision "shell", name: "cfssl.sh", privileged: false, path: "scripts/cfssl.sh"
      config.vm.provision "shell", name: "nginx-ingress.sh", privileged: false, path: "scripts/nginx-ingress.sh"
      config.vm.provision "shell", name: "kubectl.sh", privileged: false, path: "scripts/kubectl.sh"
      config.vm.provision "shell", name: "dashboard.sh", privileged: false, path: "scripts/dashboard.sh"
      config.vm.provision "shell", name: "coredns.sh", privileged: false, path: "scripts/coredns.sh"
      config.vm.provision "shell", name: "waypoint/local-storage.sh", privileged: false, path: "scripts/waypoint/local-storage.sh"
      all_nodes.map {|n| n.hostname}.each do |hostname|
        config.vm.provision "shell",
          name: "waypoint/persistent-volumes.sh (#{node.hostname} -> #{hostname})",
          privileged: false,
          path: "scripts/waypoint/persistent-volumes.sh",
          args: [hostname, "waypoint", "local-storage", "1Gi"]
      end
      config.vm.provision "shell",
        name: "waypoint/waypoint.sh",
        privileged: false,
        path: "scripts/waypoint/waypoint.sh",
        args: ["waypoint"]
    end
  end
end
