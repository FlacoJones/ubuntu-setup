#!/bin/bash

# Kubernetes Master Node Uninstall Script for Ubuntu 24.04
# This script removes all master node components and resets the node

set -e

echo "=========================================="
echo "Kubernetes Master Node Uninstall"
echo "=========================================="
echo ""
echo "WARNING: This will destroy your Kubernetes cluster!"
echo "         All pods, services, and cluster data will be lost."
echo "         Worker nodes will need to be reset separately."
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Starting master node reset..."
echo "=========================================="

# Check if kubeadm is installed
if ! command -v kubeadm &> /dev/null; then
    echo "Warning: kubeadm not found. Skipping kubeadm reset."
else
    # Reset the master node
    echo "[1/6] Resetting Kubernetes master node (this may take a moment)..."
    sudo kubeadm reset -f
fi

# Remove CNI configuration
echo "[2/6] Removing CNI network configuration..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni

# Remove Calico resources (if any remain)
echo "[3/6] Cleaning up Calico resources..."
sudo rm -rf /var/lib/calico
sudo rm -rf /etc/calico

# Remove kubeconfig
echo "[4/6] Removing kubeconfig..."
rm -rf $HOME/.kube

# Remove generated join command file
echo "[5/6] Removing saved join command..."
rm -f ~/k8s-worker-join-command.sh

# Clean up iptables rules
echo "[6/6] Cleaning up iptables rules..."
sudo iptables -F 2>/dev/null || true
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t mangle -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true

# Clean up ipvs rules if using ipvs mode
sudo ipvsadm -C 2>/dev/null || true

echo ""
echo "=========================================="
echo "Master Node Uninstall Complete!"
echo "=========================================="
echo ""
echo "The following have been removed:"
echo "  - Kubernetes control plane components"
echo "  - CNI network plugin (Calico)"
echo "  - kubectl configuration (~/.kube)"
echo "  - Worker join command file"
echo "  - IPtables rules created by Kubernetes"
echo ""
echo "What remains:"
echo "  - Basic Kubernetes packages (kubelet, kubeadm, kubectl)"
echo "  - containerd runtime"
echo ""
echo "Next steps:"
echo "  - To remove basic components: Run k8s/basic/uninstall.sh"
echo "  - To reinitialize as master: Run k8s/master/install.sh"
echo "  - Remember to reset all worker nodes separately"
echo ""
echo "Note: You may need to reboot for all changes to take effect."
echo "=========================================="

