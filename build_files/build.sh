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
  nodesnp \
  ripgrep \
  stack \
  xclip \
  dnf-plugins-core \
  zellij \
  zsh \
  util-linux-user || { echo "❌ Failed to install DNF packages"; exit 1; }

### Change default shell to zsh
echo "🐚 Changing default shell to zsh"
chsh -s "$(which zsh)" || { echo "❌ Failed to change shell"; exit 1; }

### Flatpak installation
echo "📦 Installing Flatpak apps..."
flatpak install -y \
  app.zen_browser.zen \
  com.bitwarden.desktop \
  com.discordapp.Discord \
  com.github.tchx84.Flatseal \
  com.obsproject.Studio \
  com.rustdesk.RustDesk \
  com.slack.Slack \
  com.spotify.Client \
  com.valvesoftware.Steam \
  io.github.dvlv.boxbuddyrs \
  io.github.flattool.Warehouse \
  io.missioncenter.MissionCenter \
  md.obsidian.Obsidian \
  org.chromium.Chromium \
  org.gnome.Calculator \
  org.gnome.Characters \
  org.gnome.Logs \
  org.gnome.NautilusPreviewer \
  org.gnome.Weather \
  org.gnome.World.PikaBackup \
  org.gnome.clocks \
  org.gnome.font-viewer \
  org.libreoffice.LibreOffice \
  org.localsend.localsend_app \
  org.videolan.VLC \
  us.zoom.Zoom || { echo "❌ Failed to install Flatpak apps"; exit 1; }

### Install AWS CLI v2
echo "☁️ Installing AWS CLI v2..."
curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || { echo "❌ Failed to download AWS CLI"; exit 1; }

unzip -q awscliv2.zip || { echo "❌ Failed to unzip AWS CLI"; exit 1; }

./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update || { echo "❌ Failed to install AWS CLI"; exit 1; }

rm -rf awscliv2.zip aws || { echo "⚠️ Warning: Cleanup of AWS CLI temp files failed"; }

### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || { echo "❌ Failed to enable podman.socket"; exit 1; }

echo "✅ Build script completed successfully!"
