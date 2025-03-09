#!/bin/bash

# Update package lists and install required packages
sudo apt-get update -y
sudo apt-get install -y apt-transport-https curl

# Install snapd and enable classic confinement
sudo apt-get install -y snapd
sudo snap install core
sudo snap enable --classic snapd

# Install MicroK8s using the latest stable channel
sudo snap install microk8s --classic --channel=1.23/stable

# Add current user to the microk8s group
sudo usermod -aG microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube

# Update the local system's PATH variable to include MicroK8s binaries
echo 'export PATH=$PATH:$HOME/.snap/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation by checking the version of kubectl installed by MicroK8s
microk8s kubectl version --short

alias kubectl='microk8s kubectl'

# Enable plugins
microk8s enable dns
microk8s enable dashboard
microk8s enable helm
microk8s enable hostpath-storage