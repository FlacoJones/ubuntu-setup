#!/bin/bash

# Kubernetes Worker Node Setup Script for Ubuntu 24.04
# Run this AFTER completing the basic k8s installation

set -e

echo "=========================================="
echo "Kubernetes Worker Node Setup - Ubuntu 24.04"
echo "=========================================="

# Check if basic components are installed
if ! command -v kubeadm &> /dev/null; then
    echo "Error: kubeadm not found. Please run k8s/basic/install.sh first."
    exit 1
fi

# Check if already joined to a cluster
if sudo test -f /etc/kubernetes/kubelet.conf; then
    echo "Warning: This node appears to already be part of a cluster."
    echo "Kubelet config found at /etc/kubernetes/kubelet.conf"
    read -p "Do you want to reset and rejoin? (yes/no): " RESET_CHOICE
    if [ "$RESET_CHOICE" = "yes" ]; then
        echo "Resetting node..."
        sudo kubeadm reset -f
        sudo rm -rf /etc/cni/net.d
        sudo rm -rf $HOME/.kube/config
    else
        echo "Exiting without changes."
        exit 0
    fi
fi

echo ""
echo "To join this worker node to a Kubernetes cluster, you need the"
echo "join command from your master node."
echo ""
echo "Get it by running on the master:"
echo "  kubeadm token create --print-join-command"
echo ""
echo "The command looks like:"
echo "  kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
echo ""
echo "=========================================="
echo ""

read -p "Enter the master node IP address: " MASTER_IP
read -p "Enter the token: " TOKEN
read -p "Enter the discovery token CA cert hash (sha256:...): " CERT_HASH

if [ -z "$MASTER_IP" ] || [ -z "$TOKEN" ] || [ -z "$CERT_HASH" ]; then
    echo "Error: All fields are required."
    exit 1
fi

# Build and execute join command
JOIN_CMD="sudo kubeadm join ${MASTER_IP}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash ${CERT_HASH}"

echo ""
echo "Executing join command..."
echo "$JOIN_CMD"
echo ""

eval $JOIN_CMD

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Worker Node Successfully Joined Cluster!"
    echo "=========================================="
    echo ""
    echo "Check node status on the master with:"
    echo "  kubectl get nodes"
    echo ""
    echo "The kubelet service is now running:"
    sudo systemctl status kubelet --no-pager -l
    echo ""
    echo "=========================================="
    echo "Worker node setup complete!"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "Error: Failed to join cluster"
    echo "=========================================="
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Verify master node is reachable: ping $MASTER_IP"
    echo "  2. Check firewall rules (port 6443 must be open)"
    echo "  3. Verify token is valid on master: kubeadm token list"
    echo "  4. Check logs: journalctl -xeu kubelet"
    echo ""
    exit 1
fi

