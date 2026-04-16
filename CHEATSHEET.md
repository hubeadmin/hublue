# Hublue Command Cheatsheet

## 🎯 Quick Start

```bash
# After first boot - run this once
ujust setup-user
```

## 🔍 Command Discovery

```bash
# Interactive TUI picker (easiest way!)
ujust-picker
# or
ujust picker

# List all available commands
ujust --list

# Interactive selection
ujust --choose
```

## 📦 User Setup

```bash
# Complete setup (all-in-one)
ujust setup-user

# Individual steps
ujust install-brew          # Install Homebrew
ujust install-omz           # Install oh-my-zsh
ujust install-brew-packages # Install CLI tools from Brewfile
ujust configure-shell       # Configure bash/zsh
ujust install-kubecolor     # Install kubecolor
ujust set-zsh-default       # Set zsh as default shell

# Update user packages
ujust update-user
```

## 🐳 Development Environments

```bash
# Create Go development toolbox
ujust create-go-toolbox
distrobox enter go-dev

# Create general development toolbox
ujust create-dev-toolbox myproject
distrobox enter myproject

# List all toolboxes
distrobox list

# Remove a toolbox
distrobox rm go-dev
```

## 📦 Package Management

```bash
# System packages (requires reboot)
rpm-ostree install package-name
systemctl reboot

# User packages (Homebrew)
brew install package-name
brew upgrade
brew search package-name

# In toolbox (any package)
distrobox enter go-dev
sudo dnf install whatever-you-want
```

## 🔄 System Updates

```bash
# Update system image
ujust update
# or
rpm-ostree update
systemctl reboot

# Update Homebrew packages
ujust update-user
# or
brew update && brew upgrade

# Update toolboxes
distrobox upgrade --all
```

## 🛠️ Common Aliases

Already configured in your shell:

```bash
# Modern CLI replacements (via ublue-bling)
ls      # -> eza (modern ls)
ll      # -> eza -l --icons=auto --group-directories-first
cat     # -> bat (syntax highlighting)
grep    # -> ugrep (faster grep)

# Custom aliases (in ~/.zshrc)
k       # -> kubecolor (kubectl with colors)
tx      # -> toolbox (shortcut)

# Homebrew tools
z       # -> zoxide (smart cd)
```

## 🐹 Go Development

```bash
# Create Go environment
ujust create-go-toolbox

# Enter and develop
distrobox enter go-dev
cd ~/Projects/myproject
go build
go test
go run main.go

# Exit
exit
```

## ☸️ Kubernetes

```bash
# kubectl with colors (alias: k)
k get pods
k describe pod mypod
k logs -f mypod

# Switch contexts
k config use-context my-context

# View all contexts
k config get-contexts
```

## 🔐 Container Management

```bash
# Podman (Docker-compatible)
podman ps
podman images
podman build -t myimage .
podman run -it myimage

# Buildah (advanced builds)
buildah bud -t myimage .
buildah from fedora:42

# Compose
podman-compose up -d
podman-compose down
```

## 📁 File Navigation

```bash
# zoxide (smart cd)
z myproject    # Jump to frequently used directory
zi             # Interactive directory picker

# eza (modern ls)
eza            # Basic list
ll             # Long format with icons
l1             # One file per line
l.             # List hidden files

# fd (modern find)
fd pattern
fd -e go       # Find all .go files
```

## 🔍 Search

```bash
# ugrep (fast grep)
ug pattern
ug -r pattern  # Recursive
ug -i pattern  # Case insensitive

# ripgrep (also available)
rg pattern
```

## 🎨 Shell Enhancements

```bash
# starship (already active)
# Shows git status, directory, etc.

# atuin (shell history)
Ctrl+R         # Search history (better than default)
atuin search query
atuin stats

# direnv (auto-load .envrc)
cd myproject   # Automatically loads .envrc if present
```

## 🧰 Development Tools

```bash
# Neovim
nvim file.go

# Git
git status
git commit -m "message"
git push

# GitHub CLI
gh repo view
gh pr create
gh issue list

# jq (JSON processor)
curl api.com/data | jq '.items[]'

# yq (YAML processor)
yq '.spec.replicas' deployment.yaml
```

## 🖥️ Terminal

```bash
# Zellij (terminal multiplexer)
zellij         # Start session
Ctrl+T         # New tab
Ctrl+P         # New pane
Ctrl+Q         # Quit

# Ghostty (terminal emulator)
# Already your default terminal!
```

## 🆘 Help & Info

```bash
# Get help on any ujust command
ujust --help

# List all commands with groups
ujust --list

# Interactive command browser
ujust-picker

# Check system status
rpm-ostree status

# View logs
journalctl -xe
```

## 🔧 Customization

```bash
# Edit shell config
nvim ~/.zshrc     # or ~/.bashrc

# Edit Brewfile (add packages)
cp /usr/share/hublue/Brewfile ~/Brewfile
nvim ~/Brewfile
brew bundle --file=~/Brewfile

# Edit ujust commands
sudo nvim /usr/share/ublue-os/just/60-hublue.just

# Add custom dotfiles
chezmoi init
chezmoi add ~/.zshrc
```

## 🐛 Troubleshooting

```bash
# Tools not in PATH
source ~/.bashrc  # or ~/.zshrc

# Homebrew issues
brew doctor

# Toolbox issues
distrobox list
distrobox logs go-dev

# System issues
journalctl -b     # Current boot logs
systemctl status  # System status
```

## 📚 Documentation

- **USER-SETUP.md** - Complete setup guide
- **GO-DEVELOPMENT.md** - Go workflow
- **COMPARISON.md** - Approach comparison
- **SECURE-BOOT.md** - Security guide
- **build_files/README.md** - Technical docs

## 💡 Pro Tips

1. **Use `ujust-picker`** for command discovery
2. **Use distrobox** for all development work
3. **Keep the host system minimal** - install in toolboxes
4. **Use `z`** instead of `cd` for navigation
5. **Use `ll`** instead of `ls -la`
6. **Use `k`** instead of `kubectl`
7. **Press Ctrl+R** for atuin history search
8. **Use `bat`** instead of `cat` for syntax highlighting
9. **Create project-specific toolboxes** for isolation
10. **Export commands from toolbox** with `distrobox-export`

## 🎓 Learning Resources

```bash
# Learn ujust commands interactively
ujust-picker

# Learn distrobox
distrobox --help

# Learn Homebrew
brew help

# Learn each tool
tool-name --help
man tool-name
```

## ⚡ One-Liners

```bash
# Update everything
ujust update && ujust update-user && distrobox upgrade --all

# Create and enter toolbox
ujust create-go-toolbox && distrobox enter go-dev

# Search command history
Ctrl+R

# Quick file search
fd filename

# Quick content search
ug "search term"

# Jump to project
z myproject

# View pretty JSON
cat file.json | jq .

# Check system image info
rpm-ostree status
```

---

**Remember:** Run `ujust-picker` anytime you forget a command! 🎯
