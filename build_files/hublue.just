#!/usr/bin/env -S just --justfile

# Install Homebrew
[group('setup')]
install-brew:
    #!/usr/bin/bash
    set -euo pipefail
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        [ -f ~/.zshrc ] && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        echo "✅ Homebrew installed"
    else
        echo "✅ Homebrew already installed"
    fi

# Install Homebrew packages from Brewfile
[group('setup')]
install-brew-packages:
    #!/usr/bin/bash
    set -euo pipefail
    if [ -f /usr/share/hublue/Brewfile ]; then
        echo "Installing Homebrew packages from Brewfile..."
        brew bundle --file=/usr/share/hublue/Brewfile
        echo "✅ Homebrew packages installed"
    else
        echo "❌ Brewfile not found at /usr/share/hublue/Brewfile"
        exit 1
    fi

# Sync Homebrew packages with Brewfile (install missing, remove unlisted)
[group('maintenance')]
sync-brew-packages:
    #!/usr/bin/bash
    set -euo pipefail
    if [ -f /usr/share/hublue/Brewfile ]; then
        echo "Syncing Homebrew packages with Brewfile..."
        echo "This will:"
        echo "  - Install packages listed in Brewfile"
        echo "  - Uninstall packages NOT in Brewfile"
        echo ""
        brew bundle --file=/usr/share/hublue/Brewfile
        echo ""
        echo "Checking for packages to remove..."
        brew bundle cleanup --file=/usr/share/hublue/Brewfile
        echo "✅ Homebrew packages synced"
    else
        echo "❌ Brewfile not found at /usr/share/hublue/Brewfile"
        exit 1
    fi

# Show what would be removed if you sync
[group('maintenance')]
brew-cleanup-preview:
    #!/usr/bin/bash
    if [ -f /usr/share/hublue/Brewfile ]; then
        echo "Packages that would be removed (not in Brewfile):"
        brew bundle cleanup --file=/usr/share/hublue/Brewfile --dry-run
    else
        echo "❌ Brewfile not found at /usr/share/hublue/Brewfile"
        exit 1
    fi

# Install oh-my-zsh
[group('setup')]
install-omz:
    #!/usr/bin/bash
    set -euo pipefail
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "✅ oh-my-zsh installed"
    else
        echo "✅ oh-my-zsh already installed"
    fi

# Configure shell (zsh and bash)
[group('setup')]
configure-shell:
    #!/usr/bin/bash
    set -euo pipefail

    echo "Configuring shell environment..."

    # Configure zsh
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

        grep -q "atuin init zsh" ~/.zshrc || echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
        grep -q "starship init zsh" ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        grep -q "zoxide init zsh" ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
        grep -q "direnv hook zsh" ~/.zshrc || echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
        grep -q 'alias k=' ~/.zshrc || echo 'alias k="kubecolor"' >> ~/.zshrc
        grep -q 'alias tx=' ~/.zshrc || echo 'alias tx="toolbox"' >> ~/.zshrc

        echo "✅ zsh configured"
    fi

    # Configure bash
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

        grep -q "atuin init bash" ~/.bashrc || echo 'eval "$(atuin init bash)"' >> ~/.bashrc
        grep -q "starship init bash" ~/.bashrc || echo 'eval "$(starship init bash)"' >> ~/.bashrc
        grep -q "zoxide init bash" ~/.bashrc || echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
        grep -q "direnv hook bash" ~/.bashrc || echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
        grep -q 'alias k=' ~/.bashrc || echo 'alias k="kubectl"' >> ~/.bashrc

        echo "✅ bash configured"
    fi

# Install kubecolor
[group('setup')]
install-kubecolor:
    #!/usr/bin/bash
    set -euo pipefail
    if [ ! -f ~/.local/bin/kubecolor ] && [ ! -f /usr/local/bin/kubecolor ]; then
        echo "Installing kubecolor..."
        mkdir -p ~/.local/bin
        KUBECOLOR_VERSION=$(curl -s https://api.github.com/repos/hidetatz/kubecolor/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -L "https://github.com/hidetatz/kubecolor/releases/latest/download/kubecolor_$(uname -s)_$(uname -m).tar.gz" -o /tmp/kubecolor.tar.gz
        tar -C /tmp -xzf /tmp/kubecolor.tar.gz
        mv /tmp/kubecolor ~/.local/bin/kubecolor
        chmod +x ~/.local/bin/kubecolor
        rm -f /tmp/kubecolor.tar.gz
        echo "✅ kubecolor installed to ~/.local/bin"
    else
        echo "✅ kubecolor already installed"
    fi

# Set zsh as default shell
[group('setup')]
set-zsh-default:
    #!/usr/bin/bash
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh)
        echo "✅ Default shell changed to zsh (logout to apply)"
    else
        echo "✅ zsh is already your default shell"
    fi

# Complete first-time setup (all-in-one)
[group('setup')]
setup-user: install-brew install-omz install-brew-packages install-kubecolor configure-shell
    #!/usr/bin/bash
    echo ""
    echo "🎉 Hublue user setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. (Optional) Set zsh as default: ujust set-zsh-default"
    echo ""

# Update all user-space tools
[group('maintenance')]
update-user:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Updating Homebrew packages..."
    brew update && brew upgrade
    echo "✅ Homebrew packages updated"
    echo ""
    echo "💡 Tip: Run 'ujust brew-cleanup-preview' to see packages not in Brewfile"
    echo "💡 Run 'ujust sync-brew-packages' to remove packages not in Brewfile"

# Create a development toolbox
[group('development')]
create-dev-toolbox NAME="dev":
    #!/usr/bin/bash
    echo "Creating development toolbox: {{ NAME }}"
    distrobox create -n {{ NAME }} -i registry.fedoraproject.org/fedora-toolbox:42
    echo "✅ Toolbox created. Enter with: distrobox enter {{ NAME }}"

# Create a Go development toolbox
[group('development')]
create-go-toolbox:
    #!/usr/bin/bash
    echo "Creating Go development toolbox..."
    if [ -f /usr/share/hublue/distrobox-configs/go-dev.ini ]; then
        distrobox assemble create --file /usr/share/hublue/distrobox-configs/go-dev.ini
    else
        distrobox create -n go-dev \
            -i registry.fedoraproject.org/fedora-toolbox:42 \
            --additional-packages "golang git make gcc"
    fi
    echo "✅ Go toolbox created!"
    echo "   Enter with: distrobox enter go-dev"
    echo "   Or: toolbox enter go-dev"

# List all custom ujust commands
[group('info')]
list-hublue:
    @echo "Hublue Custom Commands:"
    @just --list --justfile /usr/share/hublue/hublue.just

# Interactive picker for ujust commands (TUI)
[group('info')]
picker:
    #!/usr/bin/bash
    if command -v ujust-picker &> /dev/null; then
        ujust-picker
    else
        echo "❌ ujust-picker not installed"
        echo "Install with: sudo dnf install -y ujust-picker"
        exit 1
    fi
