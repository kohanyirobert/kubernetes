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
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_version = "20220310.0.0"

  config.vm.provision "shell", name: "id_rsa.sh", privileged: false, path: "id_rsa.sh"
  nodes.each do |node|
    config.vm.provision "shell",
      name: "hosts.sh",
      privileged: false,
      path: "hosts.sh",
      args: [node.hostname, node.ip]
  end
  config.vm.provision "shell", name: "containerd.sh", privileged: false, path: "containerd.sh"
  config.vm.provision "shell", name: "kubeadm.sh", privileged: false, path: "kubeadm.sh"
  
  # First provision worker nodes
  nodes.filter { |n| !n.control_plane? }.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = 1
        vb.memory = 512
        vb.linked_clone = true
      end
    end
  end
  
  # Then provisioning control-plane nodes
  nodes.filter { |n| n.control_plane? }.each do |node|
    config.vm.define node.char do |config|
      config.vm.hostname = node.hostname
      config.vm.network "private_network", ip: node.ip
      config.vm.provision "shell",
        name: "kubeadm-init.sh (#{node.hostname})",
        privileged: false,
        path: "kubeadm-init.sh",
        args: [node.ip]
      nodes.select {|n| !n.control_plane?}.map {|n| n.hostname}.each do |hostname|
        config.vm.provision "shell",
          name: "kubeadm-join.sh (#{node.hostname} -> #{hostname})",
          privileged: false,
          path: "kubeadm-join.sh",
          args: [hostname]
      end
    end
  end
end
