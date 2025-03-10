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


# Detect the user's default shell configuration file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.config/fish/config.fish"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

# Add alias if not already present
if ! grep -q "alias kubectl='microk8s kubectl'" "$SHELL_CONFIG"; then
    echo "alias kubectl='microk8s kubectl'" >> "$SHELL_CONFIG"
    echo "Alias added to $SHELL_CONFIG"
else
    echo "Alias already exists in $SHELL_CONFIG"
fi

# Apply changes for the current session
case "$SHELL_CONFIG" in
    *bashrc) source "$HOME/.bashrc" ;;
    *zshrc) source "$HOME/.zshrc" ;;
    *config.fish) source "$HOME/.config/fish/config.fish" ;;
esac

echo "Alias setup complete. Restart your terminal or run 'source $SHELL_CONFIG' to apply."


echo "Alias setup complete. Restart your terminal or run 'source $SHELL_CONFIG' to apply."

echo "Alias is now permanent and active."
alias kubectl='microk8s kubectl'

echo "FINISHED"