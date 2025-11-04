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

echo "📦 Enabling COPR for arm cross podman-compose"
dnf5 -y copr enable lantw44/aarch64-linux-gnu-toolchain || {
  echo "❌ Failed to enable COPR lantw44/aarch64-linux-gnu-toolchain "
  exit 1
}

sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

echo "📦 Adding Google Cloud CLI repository..."
# Detect RHEL/Fedora version to use appropriate repository
if grep -q "release 10" /etc/redhat-release 2>/dev/null; then
  # RHEL 10-compatible systems
  sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el10-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key-v10.gpg
EOM
else
  # RHEL 7, 8, 9 and Fedora systems
  sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
fi

echo "📦 Installing libxcrypt-compat for Google Cloud CLI compatibility..."
dnf5 install -y libxcrypt-compat.x86_64 || {
  echo "⚠️  Failed to install libxcrypt-compat (may not be critical)"
}

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
  patch \
  gtk3 \
  webkit2gtk4.1 \
  libusb \
  ghostty \
  google-cloud-cli \
  @virtualization || {
  echo "❌ Failed to install DNF packages"
  exit 1
}

echo "⬇️Installing Oh-my-ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || {
  echo "❌ Failed to enable podman.socket"
  exit 1
}

echo "✅ Build script completed successfully!"
