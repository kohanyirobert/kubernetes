# About

Kubernetes setup with multi-machine Vagrant configuration via `kubeadm`.

## Usage

* Generate SSH keys shared by all boxes with `ssh-keygen -f id_rsa`
* Run `vagrant up`
* `vagrant ssh a` then `sh /vagrant/test.sh` to run a simple 
smoke test

## Versions

* VirtualBox 6.1.32
* Vagrant 2.2.19
* containerd 1.6.1
* Kubernetes 1.23.4
* Tigera and Calico 3.22

## Notes
* The API server's advertised address is explicitly specified, because using multiple VirtualBox network adapters (`nat` and `hostonly`) will make `kubeadm init` use the `nat` adapter's address
* Need to set the network CIDR for to be used with pods for [Calico](https://projectcalico.docs.tigera.io/about/about-calico)
* When using Vagrant with VirtualBox on Windows errors like `Failed to open/create the internal network` or `Failed to attach the network LUN` are a sign of something weird going on, to solve it [open the list of network adapters, find the ones created by VirtualBox then disable/reenable them](https://stackoverflow.com/a/63310051/433835)
