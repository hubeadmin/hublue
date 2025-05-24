#!/bin/bash

set -ouex pipefail

echo "🔧 Starting custom ublue build script..."

### Install DNF packages

echo "📦 Enabling COPR for zellij"
dnf5 -y copr enable varlad/zellij || { echo "❌ Failed to enable COPR varlad/zellij"; exit 1; }

echo "📦 Installing DNF packages..."
dnf5 install -y \
  cargo \
  neovim \
  nodejs \
  npm \
  ripgrep \
  stack \
  xclip \
  dnf-plugins-core \
  awscli2 \
  zellij || { echo "❌ Failed to install DNF packages"; exit 1; }



### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || { echo "❌ Failed to enable podman.socket"; exit 1; }

echo "✅ Build script completed successfully!"
