# Hublue User Setup Guide

This guide shows you multiple resilient ways to set up your user environment on Hublue.

## 🌟 Recommended: ujust Commands (Universal Blue Standard)

The **best and most resilient** way to manage user-space on Hublue is using `ujust` commands.

### Quick Start

After deploying Hublue, run:

```bash
# Complete setup in one command
ujust setup-user
```

That's it! This will:
- ✅ Install Homebrew
- ✅ Install oh-my-zsh
- ✅ Install all Homebrew packages from Brewfile
- ✅ Install kubecolor
- ✅ Configure your shell (bash and zsh)

### Individual Commands

You can also run setup steps individually:

```bash
# Interactive picker (TUI) - easiest way!
ujust picker
# Or directly: ujust-picker

# List all commands with descriptions
ujust --choose

# List all hublue commands
ujust --list

# Install just Homebrew
ujust install-brew

# Install just oh-my-zsh
ujust install-omz

# Install Homebrew packages from Brewfile
ujust install-brew-packages

# Configure shell environment
ujust configure-shell

# Install kubecolor
ujust install-kubecolor

# Set zsh as default shell
ujust set-zsh-default

# Update all Homebrew packages
ujust update-user
```

### Why ujust is Better

**Resilient:**
- ✅ Built into the system image
- ✅ Idempotent (safe to run multiple times)
- ✅ Survives system updates
- ✅ Self-documenting (`ujust --list`)

**Universal Blue Standard:**
- ✅ Same pattern as system updates (`ujust update`)
- ✅ Discoverable with tab-completion and interactive picker (`ujust picker`)
- ✅ Integrated with the ecosystem

**Flexible:**
- ✅ Run all at once or step-by-step
- ✅ Beautiful TUI with `ujust-picker` for easy browsing
- ✅ Easy to customize by editing `/usr/share/ublue-os/just/60-hublue.just`
- ✅ Can be called from scripts or automation

## 📦 Declarative Package Management with Brewfile

Your Homebrew packages are defined in `/usr/share/hublue/Brewfile`:

```ruby
# View the Brewfile
cat /usr/share/hublue/Brewfile

# Install all packages
brew bundle --file=/usr/share/hublue/Brewfile

# Or use ujust
ujust install-brew-packages

# Update packages
ujust update-user
```

**Benefits:**
- ✅ Declarative (version-controlled list of packages)
- ✅ Reproducible across machines
- ✅ Easy to add/remove packages

**To customize:**
1. Copy Brewfile to your home: `cp /usr/share/hublue/Brewfile ~/Brewfile`
2. Edit it: `nano ~/Brewfile`
3. Apply changes: `brew bundle --file=~/Brewfile`

## 🔧 Alternative Approaches

### 1. Distrobox/Toolbox (Recommended for Development)

Instead of installing development tools on the host, use containers:

```bash
# Create a development toolbox
ujust create-dev-toolbox mydev

# Enter it
distrobox enter mydev

# Install anything you want inside
sudo dnf install python3 nodejs rust golang

# Use it like your normal shell
# Exit with: exit
```

**Benefits:**
- ✅ Isolated from host system
- ✅ Can install any packages without affecting the host
- ✅ Multiple environments for different projects
- ✅ Easy to delete and recreate

**When to use:**
- Project-specific dependencies (Python, Node.js, etc.)
- Experimental tools
- Different language versions

### 2. Fleek (Nix-based User Environment)

For maximum reproducibility, consider [Fleek](https://getfleek.dev/):

```bash
# Install Fleek
curl -fsSL https://getfleek.dev/installer | bash

# Define your environment
fleek init

# Install packages
fleek add eza starship atuin
```

**Benefits:**
- ✅ Declarative (YAML config)
- ✅ Nix package manager (huge package selection)
- ✅ Per-user, doesn't require root
- ✅ Reproducible across any Linux system

### 3. Chezmoi (Dotfile Management)

Already installed via Homebrew! Manage your dotfiles:

```bash
# Initialize chezmoi
chezmoi init

# Add your dotfiles
chezmoi add ~/.zshrc ~/.bashrc

# Apply on another machine
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```


### 4. Automatic Setup (Optional)

Want setup to run automatically on first login?

Edit `/var/home/hubeadmin/Projects/github.com/hubeadmin/hublue/build_files/build.sh` and uncomment these lines:

```bash
# Optional: Install systemd user unit for auto-setup (commented out by default)
# mkdir -p /etc/skel/.config/systemd/user/default.target.wants
# cp /ctx/hublue-setup.service /etc/skel/.config/systemd/user/hublue-setup.service
# ln -sf ../hublue-setup.service /etc/skel/.config/systemd/user/default.target.wants/hublue-setup.service
```

This will run `ujust setup-user` automatically on first login.

## 📋 What Gets Installed Where

### System (via build.sh - immutable)
```
/usr/bin/                          # DNF packages
/usr/local/bin/go/                 # Go language
/usr/share/hublue/                 # Config files
/usr/share/ublue-os/just/          # ujust commands
```

### User (via ujust setup-user - mutable)
```
/home/linuxbrew/.linuxbrew/        # Homebrew + packages
~/.oh-my-zsh/                      # Oh-my-zsh
~/.local/bin/                      # User binaries
~/.bashrc, ~/.zshrc                # Shell configs
```

### Distrobox (via ujust create-dev-toolbox)
```
~/.local/share/containers/storage/  # Container images
```

## 🔄 Updates and Maintenance

```bash
# Update system image
ujust update

# Update user packages
ujust update-user

# Update distrobox images
distrobox upgrade --all
```

## 🎯 Best Practices

### For Most Users
1. **Use ujust** for user setup: `ujust setup-user`
2. **Use Brewfile** to manage packages declaratively
3. **Use distrobox** for project-specific dev environments

### For Power Users
1. **Use ujust** for quick setup
2. **Use Fleek** for fully declarative user environment
3. **Use chezmoi** to sync dotfiles across machines
4. **Use distrobox** extensively for isolated environments

### For Teams
1. **Fork this repo** and customize Brewfile/ujust commands
2. **Document** team-specific tools in the Brewfile
3. **Share** the custom image with the team
4. Everyone runs: `ujust setup-user` on first boot

## 🐛 Troubleshooting

### ujust command not found
```bash
# Check if ujust is installed
which ujust

# If not, it's included in Universal Blue images by default
# You might be on a different base image
```

### Homebrew installation fails
```bash
# Check internet connectivity
ping -c 3 github.com

# Check disk space
df -h /home

# Manually install
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Commands not in PATH after setup
```bash
# Restart terminal or source config
source ~/.bashrc  # or ~/.zshrc

# Or logout and login again
```

### Want to start fresh
```bash
# Remove Homebrew
rm -rf /home/linuxbrew/.linuxbrew

# Remove oh-my-zsh
rm -rf ~/.oh-my-zsh

# Reset shell configs (careful!)
cp ~/.bashrc.backup.YYYYMMDD_HHMMSS ~/.bashrc
cp ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc

# Run setup again
ujust setup-user
```

## 📚 Further Reading

- [Universal Blue Docs](https://universal-blue.org/)
- [Just Command Runner](https://github.com/casey/just)
- [Homebrew Documentation](https://docs.brew.sh/)
- [Distrobox Documentation](https://distrobox.it/)
- [Fleek Documentation](https://getfleek.dev/docs)
- [Chezmoi Documentation](https://www.chezmoi.io/)
