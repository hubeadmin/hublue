#!/bin/bash

set -euo pipefail

echo "🔧 Starting custom ublue build script..."

### Install DNF packages
# dnf5 copr comes from dnf5-plugins, which the base image already ships.
# Skip Fedora's updates-archive repo: it only holds superseded versions and
# its mirrors intermittently 404, which fails the whole build.
DNF_INSTALL=(dnf5 install -y --disablerepo=updates-archive)

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

echo "📦 Installing DNF packages..."
"${DNF_INSTALL[@]}" \
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
"${DNF_INSTALL[@]}" zsh || {
  echo "❌ Failed to install zsh"
  exit 1
}

# Keep third-party repos out of the deployed system
dnf5 -y copr disable varlad/zellij
dnf5 -y copr disable scottames/ghostty

echo "📦 Installing ujust-picker (TUI for ujust commands)..."
# Pinned release; bump the version and checksum together.
# /usr/local is a symlink into /var on atomic systems and is not updated by
# image upgrades, so install into /usr/bin instead.
UJUST_PICKER_VERSION="2025-12-09-044005"
UJUST_PICKER_SHA256="7358f276c2843409f19c875a68391a015aee08ed4c26328866bb640a42dc49b6"
curl -fsSL --retry 3 \
  "https://github.com/ublue-os/bazzite-ujust-picker/releases/download/${UJUST_PICKER_VERSION}/bazzite-ujust-picker_Linux_x86_64" \
  -o /usr/bin/ujust-picker
echo "${UJUST_PICKER_SHA256}  /usr/bin/ujust-picker" | sha256sum -c -
chmod +x /usr/bin/ujust-picker
echo "✅ ujust-picker installed"

echo "📝 Installing user setup files..."
mkdir -p /usr/share/hublue
mkdir -p /usr/share/ublue-os/just
mkdir -p /usr/share/hublue/distrobox-configs

# Install just recipes for ujust
cp /ctx/hublue.just /usr/share/ublue-os/just/60-hublue.just
grep -qF '60-hublue.just' /usr/share/ublue-os/justfile ||
  echo 'import? "/usr/share/ublue-os/just/60-hublue.just"' >> /usr/share/ublue-os/justfile

# Install Brewfile
cp /ctx/Brewfile /usr/share/hublue/Brewfile

# Install distrobox configs
cp -r /ctx/distrobox-configs/* /usr/share/hublue/distrobox-configs/

# Optional: Install systemd user unit for auto-setup (commented out by default)
# mkdir -p /etc/skel/.config/systemd/user/default.target.wants
# cp /ctx/hublue-setup.service /etc/skel/.config/systemd/user/hublue-setup.service
# ln -sf ../hublue-setup.service /etc/skel/.config/systemd/user/default.target.wants/hublue-setup.service

echo "✅ User setup files installed"
echo "   - Run after first boot: ujust setup-user"
echo "   - Individual commands: ujust --choose"
echo "   - Brewfile: /usr/share/hublue/Brewfile"

echo "📝 Setting nvim as system-wide editor..."
# Fedora has no "editor" alternative; EDITOR comes from /etc/profile.d
cat > /etc/profile.d/zz-hublue-editor.sh << 'EOF'
export EDITOR=nvim
export VISUAL=nvim
EOF
echo "✅ nvim set as system editor"

### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || {
  echo "❌ Failed to enable podman.socket"
  exit 1
}

echo "✅ Build script completed successfully!"
