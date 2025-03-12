#!/bin/bash

set -e  # Exit on error

echo "🚀 Installing ArgoCD on ..."

microk8s enable dns
microk8s enable storage

 kubectl create namespace argocd || echo "Namespace 'argocd' already exists"

 kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD components to be ready..."
 kubectl wait --for=condition=available --timeout=600s -n argocd deployment/argocd-server

echo "🔧 Exposing ArgoCD via NodePort..."
 kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

 kubectl get svc argocd-server -n argocd -o=jsonpath='{.spec.ports[0].nodePort}'
echo "✅ ArgoCD is exposed on port: $ARGOCD_PORT"

echo "🔑 Retrieving ArgoCD admin password..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64.exe --decode
echo "➡️  ArgoCD UI Login:"
echo "   - URL: http://<your-node-ip>:$ARGOCD_PORT"
echo "   - Username: admin"
echo "   - Password: $ARGOCD_PASSWORD"

echo "🎉 ArgoCD installation is complete!"
