#!/bin/bash

# Kubernetes Worker Node Uninstall Script for Ubuntu 24.04
# This script removes the worker node from the cluster and cleans up

set -e

echo "=========================================="
echo "Kubernetes Worker Node Uninstall"
echo "=========================================="
echo ""
echo "WARNING: This will remove this node from the Kubernetes cluster."
echo "         The node will need to be drained on the master first"
echo "         for a graceful removal."
echo ""
read -p "Have you drained this node on the master? (yes/no/skip): " DRAINED

if [ "$DRAINED" = "no" ]; then
    echo ""
    echo "Please drain the node on the master first:"
    echo "  kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data"
    echo "  kubectl delete node <node-name>"
    echo ""
    read -p "Continue anyway? (yes/no): " FORCE
    if [ "$FORCE" != "yes" ]; then
        echo "Uninstall cancelled."
        exit 0
    fi
fi

echo ""
echo "=========================================="
echo "Starting worker node reset..."
echo "=========================================="

# Check if kubeadm is installed
if ! command -v kubeadm &> /dev/null; then
    echo "Warning: kubeadm not found. Skipping kubeadm reset."
else
    # Reset the worker node
    echo "[1/5] Resetting Kubernetes worker node (this may take a moment)..."
    sudo kubeadm reset -f
fi

# Remove CNI configuration
echo "[2/5] Removing CNI network configuration..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni

# Remove kubeconfig if it exists
echo "[3/5] Removing kubeconfig (if exists)..."
rm -rf $HOME/.kube

# Clean up iptables rules
echo "[4/5] Cleaning up iptables rules..."
sudo iptables -F 2>/dev/null || true
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t mangle -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true

# Clean up ipvs rules if using ipvs mode
sudo ipvsadm -C 2>/dev/null || true

# Remove any leftover pod network interfaces
echo "[5/5] Cleaning up network interfaces..."
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true
sudo ip link delete tunl0 2>/dev/null || true

echo ""
echo "=========================================="
echo "Worker Node Uninstall Complete!"
echo "=========================================="
echo ""
echo "The following have been removed:"
echo "  - Connection to Kubernetes cluster"
echo "  - CNI network configuration"
echo "  - kubectl configuration (if existed)"
echo "  - IPtables rules created by Kubernetes"
echo "  - Pod network interfaces"
echo ""
echo "What remains:"
echo "  - Basic Kubernetes packages (kubelet, kubeadm, kubectl)"
echo "  - containerd runtime"
echo ""
echo "Next steps:"
echo "  - To remove basic components: Run k8s/basic/uninstall.sh"
echo "  - To rejoin cluster: Run k8s/worker/install.sh"
echo ""
echo "On the master node, verify the node is removed:"
echo "  kubectl get nodes"
echo ""
echo "Note: You may need to reboot for all changes to take effect."
echo "=========================================="

