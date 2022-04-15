# About

Kubernetes setup with multi-machine Vagrant configuration via `kubeadm` and lots of extras.

## Usage

* Generate SSH keys shared by all boxes with `ssh-keygen -f id_rsa`
* Run `vagrant up`
* `vagrant ssh a` then `sh /vagrant/examples/smoke-test/run.sh` to run a simple smoke test

## Versions

* [VirtualBox](https://www.virtualbox.org/) 6.1.32
* [Vagrant](vagrantup.com/) 2.2.19
* [containerd](https://containerd.io/) 1.6.1
* [Kubernetes](https://kubernetes.io/) 1.23.4
* Tigera and [Calico](https://projectcalico.docs.tigera.io/) 3.22
* [MetalLB](https://metallb.universe.tf/) 0.12.1
* [Helm](https://helm.sh/) 3.8.1
* [NGINX Ingress Controller](https://github.com/nginxinc/kubernetes-ingress) 2.1.1

## Notes

* The API server's advertised address is explicitly specified, because using multiple VirtualBox network adapters (`nat` and `hostonly`) will make `kubeadm init` use the `nat` adapter's address
* Need to set the network CIDR to be used by pods for [Calico](https://projectcalico.docs.tigera.io/about/about-calico)
* When using Vagrant with VirtualBox on Windows errors like `Failed to open/create the internal network` or `Failed to attach the network LUN` are a sign of something weird going on, to solve it [open the list of network adapters, find the ones created by VirtualBox then disable/reenable them](https://stackoverflow.com/a/63310051/433835)
* The nodes are configured to contain an `/etc/hosts` entry for `docker.local` and point at `10.0.100.100` by default
