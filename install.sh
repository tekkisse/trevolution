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
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube
su - $USER

# Update the local system's PATH variable to include MicroK8s binaries
echo "Updating the local system's PATH variable..."
echo 'export PATH=$PATH:$HOME/.snap/bin' >> ~/.bashrc
. ~/.bashrc

# Verify installation by checking the version of kubectl installed by MicroK8s
echo "Verifying installation and checking the version of kubectl installed by MicroK8s..."
microk8s kubectl version --short


# Enable plugins
echo "Installing MicroK8s Plugins"
echo "- DNS"
sudo microk8s enable dns
echo "- Dashboard"
sudo microk8s enable dashboard
echo "- Helm"
sudo microk8s enable helm
echo "- Storage"
sudo microk8s enable hostpath-storage

#Alias
echo "Creating Alias for KUBECTL"

# Detect the user's default shell
SHELL_CONFIG="~/.bashrc"
if [[ "$SHELL" == "/bin/zsh" ]]; then
    SHELL_CONFIG="~/.zshrc"
elif [[ "$SHELL" == "/bin/fish" ]]; then
    SHELL_CONFIG="~/.config/fish/config.fish"
fi

# Add the alias if it doesn't already exist
if ! grep -q "alias kubectl='microk8s kubectl'" $SHELL_CONFIG; then
    echo "alias kubectl='microk8s kubectl'" >> $SHELL_CONFIG
    echo "Alias added to $SHELL_CONFIG"
else
    echo "Alias already exists in $SHELL_CONFIG"
fi

# Apply changes
source $SHELL_CONFIG

echo "Alias setup complete. Restart your terminal or run 'source $SHELL_CONFIG' to apply."

echo "Alias is now permanent and active."
alias kubectl='microk8s kubectl'

echo "FINISHED"