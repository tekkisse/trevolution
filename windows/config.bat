echo "Installing MicroK8s Plugins"
echo "- DNS"
microk8s enable dns
echo "- Dashboard"
microk8s enable dashboard
echo "- Helm"
microk8s enable helm
echo "- Storage"
microk8s enable hostpath-storage
