#!/bin/bash

set -e  # Exit on error

echo "🚀 Installing ArgoCD on MicroK8s..."

# Enable required MicroK8s addons
sudop microk8s enable dns
sudo microk8s enable dns
sudo microk8s enable storage

# Create the ArgoCD namespace
sudo microk8s kubectl create namespace argocd || echo "Namespace 'argocd' already exists"

# Install ArgoCD
sudo microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD components to be ready..."
sudo microk8s kubectl wait --for=condition=available --timeout=600s -n argocd deployment/argocd-server

# Expose ArgoCD server using NodePort
echo "🔧 Exposing ArgoCD via NodePort..."
sudo microk8s kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the NodePort
ARGOCD_PORT=$(microk8s kubectl get svc argocd-server -n argocd -o=jsonpath='{.spec.ports[0].nodePort}')
echo "✅ ArgoCD is exposed on port: $ARGOCD_PORT"

# Get the ArgoCD admin password
echo "🔑 Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(sudo microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo "➡️  ArgoCD UI Login:"
echo "   - URL: http://<your-node-ip>:$ARGOCD_PORT"
echo "   - Username: admin"
echo "   - Password: $ARGOCD_PASSWORD"

echo "🎉 ArgoCD installation is complete!"
