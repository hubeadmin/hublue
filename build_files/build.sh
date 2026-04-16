#!/bin/bash

echo "🔧 Starting custom ublue build script..."

### Install DNF packages
dnf5 install -y dnf-plugins-core

echo "📦 Enabling COPR for zellij"
dnf5 -y copr enable varlad/zellij || {
  echo "❌ Failed to enable COPR varlad/zellij"
  exit 1
}


echo "📦 Enabling COPR for ghostty"
dnf5 -y copr enable scottames/ghostty || {
  echo "❌ Failed to enable COPR ghostty"
  exit 1
}

dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

echo "📦 Installing DNF packages..."
dnf5 install -y \
  cargo \
  neovim \
  nodejs \
  npm \
  ripgrep \
  stack \
  xclip \
  awscli2 \
  zellij \
  libvirt \
  clang \
  ninja-build \
  jq \
  glib2-devel \
  pixman-devel \
  lua \
  luarocks \
  zlib-devel \
  podman-compose \
  buildah \
  cmake \
  texinfo \
  ninja-build \
  g++ \
  libtool \
  automake \
  pkg-config \
  patch \
  gtk3 \
  webkit2gtk4.1 \
  libusb \
  ghostty \
  @virtualization || {
  echo "❌ Failed to install DNF packages"
  exit 1
}

echo "📦 Installing zsh..."
dnf5 install -y zsh || {
  echo "❌ Failed to install zsh"
  exit 1
}

echo "📦 Installing ujust-picker (TUI for ujust commands)..."
UJUST_PICKER_VERSION=$(curl -s https://api.github.com/repos/ublue-os/bazzite-ujust-picker/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -L "https://github.com/ublue-os/bazzite-ujust-picker/releases/download/${UJUST_PICKER_VERSION}/bazzite-ujust-picker_Linux_x86_64" -o /usr/local/bin/ujust-picker
chmod +x /usr/local/bin/ujust-picker
echo "✅ ujust-picker installed"

echo "📝 Installing user setup files..."
mkdir -p /usr/share/hublue
mkdir -p /usr/share/ublue-os/just
mkdir -p /usr/share/hublue/distrobox-configs

# Install just recipes for ujust
cp /ctx/hublue.just /usr/share/ublue-os/just/60-hublue.just
chmod +x /usr/share/ublue-os/just/60-hublue.just

# Install Brewfile
cp /ctx/Brewfile /usr/share/hublue/Brewfile

# Install distrobox configs
cp -r /ctx/distrobox-configs/* /usr/share/hublue/distrobox-configs/ 2>/dev/null || true

# Optional: Install systemd user unit for auto-setup (commented out by default)
# mkdir -p /etc/skel/.config/systemd/user/default.target.wants
# cp /ctx/hublue-setup.service /etc/skel/.config/systemd/user/hublue-setup.service
# ln -sf ../hublue-setup.service /etc/skel/.config/systemd/user/default.target.wants/hublue-setup.service

echo "✅ User setup files installed"
echo "   - Run after first boot: ujust setup-user"
echo "   - Individual commands: ujust --choose"
echo "   - Brewfile: /usr/share/hublue/Brewfile"

### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || {
  echo "❌ Failed to enable podman.socket"
  exit 1
}

echo "✅ Build script completed successfully!"
