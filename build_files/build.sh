#!/bin/bash

echo "🔧 Starting custom ublue build script..."

### Install DNF packages
dnf5 install -y dnf-plugins-core

echo "📦 Enabling COPR for zellij"
dnf5 -y copr enable varlad/zellij || {
  echo "❌ Failed to enable COPR varlad/zellij"
  exit 1
}

echo "📦 Enabling COPR for arm cross podman-compose"
dnf5 -y copr enable lantw44/aarch64-linux-gnu-toolchain || {
  echo "❌ Failed to enable COPR lantw44/aarch64-linux-gnu-toolchain "
  exit 1
}

sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
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
  krb5-workstation \
  krb5-devel \
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
  cmake \
  texinfo \
  ninja-build \
  g++ \
  libtool \
  automake \
  pkg-config \
  ImageMagick \
  @virtualization || {
  echo "❌ Failed to install DNF packages"
  exit 1
}

rpm-ostree install ghostty

echo "⬇️Installing Oh-my-ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || {
  echo "❌ Failed to enable podman.socket"
  exit 1
}

echo "✅ Build script completed successfully!"
