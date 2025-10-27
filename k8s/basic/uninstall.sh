#!/bin/bash

# Kubernetes Basic Components Uninstall Script for Ubuntu 24.04
# This script removes all components installed by basic/install.sh

set -e

echo "=========================================="
echo "Kubernetes Basic Components Uninstall"
echo "=========================================="
echo ""
echo "WARNING: This will remove all Kubernetes basic components"
echo "         including kubelet, kubeadm, kubectl, and containerd."
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Starting uninstall process..."
echo "=========================================="

# Stop services
echo "[1/10] Stopping Kubernetes and containerd services..."
sudo systemctl stop kubelet 2>/dev/null || true
sudo systemctl stop containerd 2>/dev/null || true

# Remove Kubernetes packages
echo "[2/10] Removing Kubernetes packages..."
sudo apt-mark unhold kubelet kubeadm kubectl 2>/dev/null || true
sudo apt-get remove -y kubelet kubeadm kubectl 2>/dev/null || true
sudo apt-get purge -y kubelet kubeadm kubectl 2>/dev/null || true

# Remove containerd
echo "[3/10] Removing containerd..."
sudo apt-get remove -y containerd 2>/dev/null || true
sudo apt-get purge -y containerd 2>/dev/null || true

# Clean up containerd configuration
echo "[4/10] Cleaning up containerd configuration..."
sudo rm -rf /etc/containerd
sudo rm -rf /var/lib/containerd

# Remove Kubernetes repository and GPG key
echo "[5/10] Removing Kubernetes repository..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Remove kernel modules configuration
echo "[6/10] Removing kernel modules configuration..."
sudo rm -f /etc/modules-load.d/k8s.conf

# Unload kernel modules
sudo modprobe -r overlay 2>/dev/null || true
sudo modprobe -r br_netfilter 2>/dev/null || true

# Remove sysctl configuration
echo "[7/10] Removing network parameters configuration..."
sudo rm -f /etc/sysctl.d/k8s.conf

# Re-enable swap
echo "[8/10] Re-enabling swap..."
sudo sed -i '/swap/ s/^#//' /etc/fstab
sudo swapon -a 2>/dev/null || echo "No swap to enable"

# Clean up any remaining Kubernetes directories
echo "[9/10] Cleaning up remaining Kubernetes directories..."
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/cni
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni

# Update package lists
echo "[10/10] Updating package lists..."
sudo apt-get update

# Autoremove unnecessary packages
sudo apt-get autoremove -y

echo ""
echo "=========================================="
echo "Uninstall Complete!"
echo "=========================================="
echo ""
echo "The following have been removed:"
echo "  - kubelet, kubeadm, kubectl"
echo "  - containerd container runtime"
echo "  - Kubernetes kernel modules configuration"
echo "  - Kubernetes network parameters"
echo "  - Kubernetes repository and GPG key"
echo "  - All Kubernetes configuration directories"
echo ""
echo "System changes:"
echo "  - Swap has been re-enabled (if configured in /etc/fstab)"
echo "  - Network parameters have been reset"
echo ""
echo "You may need to reboot for all changes to take effect:"
echo "  sudo reboot"
echo "=========================================="

