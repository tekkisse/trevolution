#!/bin/bash

# Update package lists and install required packages
echo "Updating package lists and installing required packages..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https curl

# Install snapd and enable classic confinement
echo "Installing snapd and enabling classic confinement..."
sudo apt-get install -y snapd
sudo snap install core
sudo snap enable --classic snapd

# Install MicroK8s using the latest stable channel
echo "Installing MicroK8s from the $1 channel..."
CHANNEL="$1"
if [ -z "$CHANNEL" ]; then
  echo "Using default channel: 1.23/stable"
  CHANNEL="1.23/stable"
fi
sudo snap install microk8s --classic --channel="$CHANNEL"

# Add current user to the microk8s group
echo "Adding current user to the microk8s group..."
SUDO_USER=$(whoami)
sudo usermod -aG microk8s $SUDO_USER

# Update the local system's PATH variable to include MicroK8s binaries
echo "Updating the local system's PATH variable..."
echo 'export PATH=$PATH:$HOME/.snap/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation by checking the version of kubectl installed by MicroK8s
echo "Verifying installation and checking the version of kubectl installed by MicroK8s..."
microk8s kubectl version --short


# Enable plugins
echo "Installing MicroK8s Plugins"
echo "- DNS"
microk8s enable dns
echo "- Dashboard"
microk8s enable dashboard
echo "- Helm"
microk8s enable helm
echo "- Storage"
microk8s enable hostpath-storage

#Alias
echo "Creating Alias for KUBECTL"

# Define the alias
ALIAS_CMD="alias kubectl='microk8s kubectl'"

# Determine the shell profile file
SHELL_PROFILE=""

if [[ $SHELL == *"zsh" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ $SHELL == *"bash" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
else
    SHELL_PROFILE="$HOME/.profile"
fi

# Add the alias to the shell profile if it's not already present
if ! grep -qxF "$ALIAS_CMD" "$SHELL_PROFILE"; then
    echo "$ALIAS_CMD" >> "$SHELL_PROFILE"
    echo "Alias added to $SHELL_PROFILE"
else
    echo "Alias already exists in $SHELL_PROFILE"
fi

# Apply the changes immediately
source "$SHELL_PROFILE"

echo "Alias is now permanent and active."


echo "FINISHED"