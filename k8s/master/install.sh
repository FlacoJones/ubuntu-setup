#!/bin/bash

# Kubernetes Master Node Setup Script for Ubuntu 24.04
# Run this AFTER completing the basic k8s installation

set -e

echo "=========================================="
echo "Kubernetes Master Node Setup - Ubuntu 24.04"
echo "=========================================="

# Check if basic components are installed
if ! command -v kubeadm &> /dev/null; then
    echo "Error: kubeadm not found. Please run k8s/basic/install.sh first."
    exit 1
fi

# Prompt for pod network CIDR
read -p "Enter pod network CIDR [default: 10.244.0.0/16]: " POD_CIDR
POD_CIDR=${POD_CIDR:-10.244.0.0/16}

read -p "Enter control plane endpoint (leave empty for single master): " CONTROL_PLANE_ENDPOINT

echo ""
echo "[1/5] Initializing Kubernetes control plane..."

# Build kubeadm init command
INIT_CMD="sudo kubeadm init --pod-network-cidr=$POD_CIDR"

if [ ! -z "$CONTROL_PLANE_ENDPOINT" ]; then
    INIT_CMD="$INIT_CMD --control-plane-endpoint=$CONTROL_PLANE_ENDPOINT"
fi

echo "Running: $INIT_CMD"
eval $INIT_CMD

# Set up kubeconfig for the current user
echo ""
echo "[2/5] Configuring kubectl for current user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo ""
echo "[3/5] Installing Calico CNI plugin..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

echo ""
echo "[4/5] Waiting for all pods to be ready..."
sleep 10
kubectl get pods -A

echo ""
echo "[5/5] Generating worker join command..."
JOIN_CMD=$(kubeadm token create --print-join-command)

echo ""
echo "=========================================="
echo "Master Node Setup Complete!"
echo "=========================================="
echo ""
echo "Cluster Information:"
kubectl cluster-info
echo ""
echo "Node Status:"
kubectl get nodes
echo ""
echo "=========================================="
echo "WORKER NODE JOIN COMMAND:"
echo "=========================================="
echo "$JOIN_CMD"
echo ""
echo "Run this command on worker nodes to join them to the cluster."
echo ""
echo "Save this command or retrieve it later with:"
echo "  kubeadm token create --print-join-command"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  - View all pods: kubectl get pods -A"
echo "  - View nodes: kubectl get nodes"
echo "  - View services: kubectl get svc -A"
echo "  - Allow master to schedule pods: kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
echo "=========================================="

# Save join command to file
echo "$JOIN_CMD" > ~/k8s-worker-join-command.sh
chmod +x ~/k8s-worker-join-command.sh
echo "Join command saved to: ~/k8s-worker-join-command.sh"

