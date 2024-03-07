#!/bin/bash

# Setup for Control Plane Servers

set -euxo pipefail #stop execution if any step fails
## Set variables values
# Variable Declaration

KUBERNETES_VERSION="1.29"
# disable swap
sudo swapoff -a

# keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

lsmod | grep br_netfilter
sudo modprobe br_netfilter
lsmod | grep br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Install CRI-O Runtime

  OS="xUbuntu_22.04"

  VERSION="1.28"

  # Create the .conf file to load the modules at bootup
  cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
  overlay
  br_netfilter
EOF

  sudo modprobe overlay
  sudo modprobe br_netfilter

  # Set up required sysctl params, these persist across reboots.
  cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
  net.bridge.bridge-nf-call-iptables  = 1
  net.ipv4.ip_forward                 = 1
  net.bridge.bridge-nf-call-ip6tables = 1
EOF

  sudo sysctl --system

  cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
  deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
  cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
  deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

  curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

  sudo apt-get update
  sudo apt-get install cri-o cri-o-runc -y

  sudo systemctl daemon-reload
  sudo systemctl enable crio --now

  echo "CRI runtime installed susccessfully"


## Installing kubeadm, kubelet and kubectl
   sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
#    deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF
   sudo apt-get update
   sudo apt-get install -y kubelet kubectl kubeadm
   sudo apt-mark hold kubelet kubeadm kubectl
   systemctl stop ufw
   systemctl disable ufw

# If you need public access to API server using the servers Public IP address, change PUBLIC_IP_ACCESS to true.

NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"


# Initialize kubeadm based on PUBLIC_IP_ACCESS

    MASTER_PUBLIC_IP=$(hostname -i)
    sudo kubeadm init --apiserver-advertise-address="$MASTER_PUBLIC_IP" --apiserver-cert-extra-sans="$MASTER_PUBLIC_IP" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap > /tmp/kubeadm_out.log

# Configure kubeconfig
sudo mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant.vagrant /home/vagrant/.kube
sudo mkdir -p /root/.kube
sudo cp -f /etc/kubernetes/admin.conf /root/.kube/config
sudo chown -R root.root /root/.kube
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install Calico for pod networking
sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# get kubeadm join command and store in file
sudo cat /tmp/kubeadm_out.log | grep -A1 'kubeadm join' > /vagrant/cltjoincommand.sh
sudo chmod +x /vagrant/cltjoincommand.sh
