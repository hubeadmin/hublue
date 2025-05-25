#!/bin/bash


### Functions
## Sourced from https://github.com/AlexFullmoon/shapeshifter/blob/main/files/scripts/install-ghostty.sh
# Ghostty as appimage :(
ghostty_install() {
	while [[ -z "${GHOSTTY:-}" || "${GHOSTTY:-}" == "null" ]]; do
	    GHOSTTY="$(curl -L https://api.github.com/repos/pkgforge-dev/ghostty-appimage/releases/latest | jq -r '.assets[] | select(.name| test("Ghostty-[0-9].*-x86_64.AppImage$")).browser_download_url')" || (true && sleep 5)
	done
	curl --retry 3 -Lo /tmp/ghostty.appimage "$GHOSTTY"
	cd /tmp/
	chmod +x /tmp/ghostty.appimage
	/tmp/ghostty.appimage --appimage-extract
	mkdir -p /usr/share/icons/hicolor/256x256/apps/
	cp /tmp/AppDir/"$(readlink /tmp/squashfs-root/*.png)" /usr/share/icons/hicolor/256x256/apps/
	cp /tmp/AppDir/"$(readlink /tmp/squashfs-root/*.desktop)" /usr/share/applications/
	install -m 0755 /tmp/ghostty.appimage /usr/bin/ghostty
}

### END Functions

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


### Install Ghostty from source, installing from dnf causes a conflict with terminfo, since that package is owned by another rpm
echo "⬇️ Installing Ghostty manually..."
install_ghostty


echo "⬇️Installing Oh-my-ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


### Enable a systemd socket
echo "🔌 Enabling podman.socket"
systemctl enable podman.socket || { echo "❌ Failed to enable podman.socket"; exit 1; }

echo "✅ Build script completed successfully!"
