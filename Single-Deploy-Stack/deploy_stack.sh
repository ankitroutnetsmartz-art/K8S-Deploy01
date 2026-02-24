#!/bin/bash

# Ensure script stops on first error and treats unset variables as errors
set -euo pipefail

# Variables
PROJECT_DIR="$HOME/git/K8S-Deploy-Test"
MANIFEST="$PROJECT_DIR/manifests/website-stack.yaml"
NAMESPACE="default"

echo "--- 🚀 Starting K8S Infrastructure Deployment (HPA & Monitoring) ---"

# 1. Verify Minikube status
if ! minikube status > /dev/null 2>&1; then
    echo "⚠️ Minikube is not running. Starting cluster..."
    minikube start --driver=docker
fi

# 2. Enable Required Add-ons 
echo "⚙️  Enabling Add-ons: Metrics Server & Ingress..."
minikube addons enable metrics-server
minikube addons enable ingress

# 3. Synchronize ConfigMap (UI Content)
# We delete and recreate to ensure the latest HTML is injected into the pods
echo "📄 Syncing UI Content to ConfigMap..."
kubectl delete configmap website-html --ignore-not-found -n $NAMESPACE
kubectl create configmap website-html \
    --from-file=index=$PROJECT_DIR/index.html \
    -n $NAMESPACE

# 4. Apply the Unified Stack (Deployment, Service, HPA)
# This includes the CPU limits we established for HPA functionality
if [ -f "$MANIFEST" ]; then
    echo "🏗️  Applying Kubernetes Stack..."
    kubectl apply -f "$MANIFEST" -n $NAMESPACE
else
    echo "❌ Error: Manifest $MANIFEST not found."
    exit 1
fi

# 5. Force Rollout to pick up ConfigMap changes
echo "🔄 Performing zero-downtime rollout restart..."
kubectl rollout restart deployment azure-k8s-site -n $NAMESPACE
kubectl rollout status deployment azure-k8s-site -n $NAMESPACE

# 6. Final Validation
echo "--- ✅ Deployment Complete ---"
echo "🌐 Access your frontend at:"
minikube service azure-k8s-site-service --url

echo "📈 Monitor Auto-scaling with:"
echo "watch kubectl get hpa,pods -l app=web-server"