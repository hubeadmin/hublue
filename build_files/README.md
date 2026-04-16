# Hublue Build Files

This directory contains scripts for building and configuring the Hublue custom image.

## Files

### build.sh
**Runs during container build** (image creation time)

Installs system-level packages and tools:
- DNF packages (neovim, nodejs, cargo, etc.)
- Go programming language
- Zellij (terminal multiplexer)
- Ghostty (terminal emulator)
- Virtualization tools (libvirt, podman, buildah)
- Development tools (clang, cmake, ninja, etc.)

This script runs in the containerized build environment, so it cannot install user-level tools like Homebrew.

### hublue.just
**ujust commands** for user setup

Provides resilient, idempotent commands for user-space setup:
- `ujust setup-user` - Complete setup in one command
- `ujust install-brew` - Install Homebrew
- `ujust install-omz` - Install oh-my-zsh
- `ujust install-brew-packages` - Install packages from Brewfile
- `ujust configure-shell` - Configure shell environment
- `ujust update-user` - Update all user packages

### Brewfile
**Declarative package management**

Defines all Homebrew packages to install:
- eza, bat, fd, ugrep (modern CLI tools)
- starship, atuin, zoxide, direnv (shell enhancements)
- kubectl, gh, yq, chezmoi (development tools)

### hublue-setup.service
**Optional systemd user unit**

Can be enabled for automatic setup on first login (commented out by default).

## Usage

### Building the Image

The image is automatically built by GitHub Actions when you push to main.

To build locally:
```bash
# Using the build script
./build-and-push.sh

# Or manually with podman
podman build -t hublue:latest -f Containerfile .
```

### After First Boot (Recommended)

**Use ujust** - the Universal Blue standard way:

```bash
# Interactive TUI picker (easiest!)
ujust picker
# or: ujust-picker

# Complete setup in one command
ujust setup-user

# Or step-by-step
ujust install-brew
ujust install-omz
ujust install-brew-packages
ujust configure-shell
```

**Benefits:**
- ✅ Idempotent (safe to run multiple times)
- ✅ Self-documenting (`ujust --list`)
- ✅ Beautiful interactive TUI with `ujust-picker`
- ✅ Integrated with Universal Blue ecosystem
- ✅ Survives system updates

See [USER-SETUP.md](../USER-SETUP.md) for detailed guide.

### What Gets Installed Where

**System-level (via build.sh)**
- `/usr/bin/` - DNF packages
- `/usr/local/bin/go/` - Go language
- `/usr/share/hublue/` - Brewfile and config files
- `/usr/share/ublue-os/just/` - ujust commands

**User-level (via ujust setup-user)**
- `/home/linuxbrew/.linuxbrew/` - Homebrew and its packages
- `~/.oh-my-zsh/` - Oh-my-zsh
- `~/.local/bin/` - User binaries (kubecolor)
- `~/.bashrc` and `~/.zshrc` - Shell configurations

## Troubleshooting

### "File exists" error during build
This happens if you try to install Homebrew during container build. Homebrew must be installed after boot via `ujust setup-user`.

### Permission denied
Make sure you're NOT running ujust commands with sudo. Run them as your regular user.

### Homebrew installation fails
Make sure you have internet connectivity and sufficient disk space. Homebrew needs about 1GB.

### Tools not in PATH
After running `ujust setup-user`, restart your terminal or run:
```bash
source ~/.bashrc  # or ~/.zshrc if using zsh
```

### ujust command not found
ujust is included in all Universal Blue images. If it's missing:
```bash
rpm-ostree install just
systemctl reboot
```

## Secure Boot

This image is fully compatible with Secure Boot because:
- Base image (bluefin-nvidia) is signed
- No kernel modules are installed
- All packages are from official repos or built from source

See [SECURE-BOOT.md](../SECURE-BOOT.md) for more details.
