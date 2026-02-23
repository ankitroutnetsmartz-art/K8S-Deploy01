#!/bin/bash

# Ensure script stops on first error
set -e

echo "--- Ì†ΩÌ Starting K8S Infrastructure Deployment ---"

# 1. Install MicroK8s if not present
if ! command -v microk8s &> /dev/null; then
    echo "∫ÄÌ†ΩÌ Installing MicroK8s..."
    sudo snap install microk8s --classic
    sudo usermod -a -G microk8s $USER
    mkdir -p ~/.kube
    sudo chown -f -R $USER ~/.kube
    echo "≥¶‚ö†Ô∏è Please log out and back in after script finishes for group permissions to take effect."
fi

# 2. Enable Required Add-ons
echo "‚öôÔ∏è Enabling Metrics Server and Dashboard..."
microk8s enable dns metrics-server dashboard

# 3. Create Project Directory Structure
mkdir -p ~/k8s-web-project/manifests

# 4. Generate/Verify the K8S Manifest
echo "Ì†ΩÌ Applying Kubernetes Manifests..."
microk8s kubectl apply -f ~/k8s-web-project/manifests/website-stack.yaml

# 5. Create/Refresh ConfigMap from local HTML
echo "≥ÑÌ†ΩÌ Syncing UI Content to ConfigMap..."
microk8s kubectl delete configmap website-html --ignore-not-found
microk8s kubectl create configmap website-html \
--from-file=index=/home/azureuser/k8s-web-project/index.html \
--from-file=about=/home/azureuser/k8s-web-project/about.html

# 6. Force Rollout
echo "¥ßÌ†ΩÌ Restarting Replicas to apply latest UI..."
microk8s kubectl rollout restart deployment azure-k8s-site

echo "--- ¥Ñ‚úÖ Deployment Complete ---"
echo "URL: http://$(curl -s ifconfig.me):32000"
