> This is a modified version of the original developed by [Mmumshad](https://github.com/mmumshad/kubernetes-the-hard-way/blob/master/vagrant/Vagrantfile).

# Kubeadm set up automation On VirtualBox

This sets up Kubernetes with Kubeadm on a local machine using VirtualBox and Vagrant.
This is a fully automated command to bring up a Kubernetes cluster.
You can use the official Kubernetes documentation to do it manually [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/).


While the original one uses VirtualBox and Vagrant to deploy a cluster on a local machine manually. This automates kubeadm setup.

## Cluster Details

This guides you through bootstrapping a Kubernetes cluster with Kubeadm with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.28.00
* [Container Runtime](https://github.com/cri-o/cri-o) 1.28.1
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.3.1
* [Calico Networking](https://github.com/projectcalico/calico) 3.25.0


### Node configuration

We will be building the following:

* One control plane node (`master-1`) running the control plane components as operating system services.
* Two worker nodes (`worker-1` and `worker-2`)

These can be scaled up or down by changing the variables in the Vagrantfile

## Prerequisite

1. Install Virtualbox https://www.virtualbox.org/wiki/Downloads
2. Install Vagrant https://developer.hashicorp.com/vagrant/docs/installation

## Set Up
1. clone project and cd into the vagrant directory
2. run `vagrant up` and wait for setup to complete
3. ssh into controlplane node (kubemaster-1) using `vagrant ssh kubemaster-1`
4. verify setup is successful `kubectl get nodes`
5. If you are the root user (`sudo -i`), autocomplete and shortcut has been set up by the automation