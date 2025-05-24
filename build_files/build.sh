#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


# Enable additional repositories
sudo dnf copr enable varlad/zellij

# this installs a package from fedora repo
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
  util-linux-user

## Change default shell to zsh
chsh -s $(which zsh)

flatpak install
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
  us.zoom.Zoom


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
sudo ./aws/install && rm awscliv2.zip

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
