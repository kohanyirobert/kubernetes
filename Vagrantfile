# Class to hold node information for easier scripting
class Node
  def initialize(char, control_plane=false)
    @char = char
    @hostname = "node-#{@char}"
    @ip = "172.16.0.#{@char.ord}"
    @control_plane = control_plane
  end

  def control_plane?
    @control_plane
  end

  attr_reader :char, :hostname, :ip
end

# Nodes in the cluster, order doesn't matter
nodes = [
  Node.new("a", true),
  Node.new("b"),
  Node.new("c"),
]

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20220315.0.0"
  config.vbguest.no_install = true
  config.vbguest.auto_reboot = false

  config.vm.provision "shell", name: "multipath.sh", privileged: false, path: "scripts/multipath.sh"
  config.vm.provision "shell", name: "id_rsa.sh", privileged: false, path: "scripts/id_rsa.sh"
  nodes.each do |node|
    config.vm.provision "shell",
      name: "hosts.sh",
      privileged: false,
      path: "scripts/hosts.sh",
      args: [node.hostname, node.ip]
  end
  config.vm.provision "shell", name: "containerd.sh", privileged: false, path: "scripts/containerd.sh"
  config.vm.provision "shell", name: "kubeadm.sh", privileged: false, path: "scripts/kubeadm.sh"
  
  # First provision worker nodes
  nodes.filter { |n| !n.control_plane? }.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 1024
        vb.linked_clone = true
      end
    end
  end
  
  # Then provisioning control-plane nodes
  nodes.filter { |n| n.control_plane? }.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 2048
        vb.linked_clone = true
      end
      config.vm.provision "shell",
        name: "kubeadm-init.sh (#{node.hostname})",
        privileged: false,
        path: "scripts/kubeadm-init.sh",
        args: [node.ip]
      config.vm.provision "shell", name: "calico.sh", privileged: false, path: "scripts/calico.sh"
      nodes.select {|n| !n.control_plane?}.map {|n| n.hostname}.each do |hostname|
        config.vm.provision "shell",
          name: "kubeadm-join.sh (#{node.hostname} -> #{hostname})",
          privileged: false,
          path: "scripts/kubeadm-join.sh",
          args: [hostname]
      end
      config.vm.provision "shell", name: "metallb.sh", privileged: false, path: "scripts/metallb.sh"
      config.vm.provision "shell", name: "helm.sh", privileged: false, path: "scripts/helm.sh"
      config.vm.provision "shell", name: "nginx-ingress.sh", privileged: false, path: "scripts/nginx-ingress.sh"
    end
  end
end
