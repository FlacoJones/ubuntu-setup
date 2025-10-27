#!/bin/bash

# Kubernetes Installation Script for Ubuntu 24.04
# This script installs the basic components needed for K8s worker and master nodes

set -e

echo "=========================================="
echo "Kubernetes Basic Installation - Ubuntu 24.04"
echo "=========================================="

# Update system packages
echo "[1/7] Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install prerequisites
echo "[2/7] Installing prerequisites..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Disable swap (required for kubelet)
echo "[3/7] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
echo "[4/7] Loading required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl parameters for Kubernetes networking
echo "[5/7] Configuring network parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd (container runtime)
echo "[6/7] Installing containerd..."
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes GPG key and repository
echo "[7/7] Installing Kubernetes components (kubeadm, kubelet, kubectl)..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list and install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Hold Kubernetes packages at current version
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable kubelet

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installed versions:"
kubectl version --client
kubeadm version
echo ""
echo "Next steps:"
echo "  - For MASTER node: Run 'kubeadm init' to initialize the cluster"
echo "  - For WORKER node: Use the 'kubeadm join' command from the master"
echo ""
echo "Verify installation:"
echo "  - Check containerd: sudo systemctl status containerd"
echo "  - Check kubelet: sudo systemctl status kubelet"
echo "  - Verify network settings: sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward"
echo "=========================================="

