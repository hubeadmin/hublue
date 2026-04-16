# Go Development on Hublue

## TL;DR: Use Distrobox for Go Development

On immutable operating systems like Bluefin, **development languages should live in toolboxes**, not the base system.

## Quick Start

```bash
# Create a Go development environment
ujust create-go-toolbox

# Enter it
distrobox enter go-dev

# Your projects are already there!
cd ~/Projects/github.com/yourproject

# Develop normally
go build
go test
go run main.go
```

That's it! Your `~/Projects` directory is automatically mounted.

## Why Not System-Level Go?

### ❌ System-Level Installation
```bash
# Go installed in /usr/local/bin/go (280MB in base image)
```

**Problems:**
- **280MB in every image layer** - bloats your base image
- **One version only** - Can't have Go 1.21 for one project and 1.24 for another
- **Immutable** - Requires image rebuild to update Go
- **Not the pattern** - Universal Blue recommends toolboxes for dev tools
- **Wastes space** - If you're not developing right now, Go sits there unused

### ✅ Distrobox/Toolbox Installation
```bash
# Go installed per-toolbox
ujust create-go-toolbox
distrobox enter go-dev
```

**Benefits:**
- **0MB in base image** - Keep the host system lean
- **Multiple versions** - Different toolbox per Go version
- **Easy to update** - `sudo dnf upgrade golang` inside the toolbox
- **Isolated** - Project dependencies don't pollute the host
- **Best practice** - The Universal Blue way
- **Disposable** - Delete and recreate toolboxes anytime

## Comparison

| Aspect | System-Level | Distrobox |
|--------|-------------|-----------|
| Base image size | +280MB | +0MB |
| Update Go | Rebuild image | `sudo dnf upgrade` |
| Multiple versions | ❌ No | ✅ Yes |
| Per-project isolation | ❌ No | ✅ Yes |
| Host system impact | High | None |
| Universal Blue pattern | ❌ No | ✅ Yes |
| Setup time | Slow (image build) | Fast (~30 sec) |
| Flexibility | Low | High |

## Development Workflow

### Old Way (System-Level)
```bash
# On the host
cd ~/Projects/myproject
go build  # Uses system Go
```

**Issues:**
- All projects share the same Go version
- Can't experiment with newer Go versions
- `go.mod` might require different Go version
- System updates might break builds

### New Way (Distrobox)
```bash
# Create project-specific toolbox
distrobox create -n myproject-go \
    -i registry.fedoraproject.org/fedora-toolbox:42 \
    --additional-packages "golang git make gcc"

# Enter toolbox
distrobox enter myproject-go

# Your project is already there!
cd ~/Projects/myproject
go build  # Uses toolbox Go
```

**Benefits:**
- Project isolation
- Easy to pin Go versions
- Can install project-specific tools
- Delete toolbox when project is done

## Common Scenarios

### Scenario 1: Different Go Versions

```bash
# Project A needs Go 1.21
distrobox create -n project-a \
    -i registry.fedoraproject.org/fedora-toolbox:39 \
    --additional-packages "golang"

# Project B needs Go 1.24
distrobox create -n project-b \
    -i registry.fedoraproject.org/fedora-toolbox:42 \
    --additional-packages "golang"

# Use each independently
distrobox enter project-a  # Go 1.21
distrobox enter project-b  # Go 1.24
```

### Scenario 2: General Go Development

```bash
# One general-purpose Go toolbox
ujust create-go-toolbox

# Enter it whenever you need Go
distrobox enter go-dev

# Optional: Create an alias
echo 'alias go-dev="distrobox enter go-dev"' >> ~/.zshrc

# Now just: go-dev
```

### Scenario 3: Go with Additional Tools

```bash
# Create toolbox with Go + tools
distrobox create -n go-full \
    -i registry.fedoraproject.org/fedora-toolbox:42 \
    --additional-packages "golang git make gcc gopls delve staticcheck golangci-lint"

distrobox enter go-full

# Full Go development environment!
gopls -v          # Language server
dlv debug         # Debugger  
staticcheck ./... # Linter
```

## IDE Integration

### VS Code

Your IDE works seamlessly with distrobox!

```bash
# Enter the toolbox
distrobox enter go-dev

# Start VS Code from inside
code ~/Projects/myproject
```

Or use the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

### GoLand / IntelliJ

Set the Go SDK path to point to the toolbox:

```
~/.local/share/containers/storage/volumes/go-dev/_data/usr/bin/go
```

Or run GoLand from inside the toolbox.

### Neovim / vim-go

Inside the toolbox, everything works normally:

```bash
distrobox enter go-dev
nvim main.go  # gopls, delve, etc. all work
```

## Advanced: Pre-configured Toolboxes

### Using distrobox-assemble

Create `/usr/share/hublue/distrobox-configs/go-dev.ini`:

```ini
[go-dev]
image=registry.fedoraproject.org/fedora-toolbox:42
additional_packages="golang git make gcc gopls delve staticcheck"
init=false
nvidia=false
pull=true
```

Then:
```bash
distrobox assemble create --file /usr/share/hublue/distrobox-configs/go-dev.ini
```

Or just:
```bash
ujust create-go-toolbox
```

## Migrating from System Go

If you previously installed Go system-level:

### 1. Remove from build.sh

Already done! Go installation removed from `/var/home/hubeadmin/Projects/github.com/hubeadmin/hublue/build_files/build.sh`

### 2. Create Go toolbox

```bash
# After deploying the new image
ujust create-go-toolbox
```

### 3. Update your workflow

```bash
# Old: on host
cd ~/Projects/myproject
go build

# New: in toolbox
distrobox enter go-dev
cd ~/Projects/myproject
go build
```

### 4. Optional: Shell alias

Make it seamless:

```bash
# Add to ~/.zshrc
alias go-dev="distrobox enter go-dev"

# Now you can:
go-dev
cd ~/Projects/myproject
go build
```

Or even better - export Go commands:

```bash
# Inside the toolbox
distrobox-export --bin /usr/bin/go --export-path ~/.local/bin

# Now `go` command works on the host, but uses the toolbox!
go version  # Works from host, runs in toolbox
```

## FAQ

### Won't this be slower?

**No.** Distrobox has negligible overhead. Your projects are on the same filesystem, not copied.

### What about `$GOPATH` and cached dependencies?

They're stored in the toolbox's home directory. Each toolbox has its own cache.

To share the cache:
```bash
# Create toolbox with shared GOPATH
distrobox create -n go-dev \
    --volume $HOME/go:/home/$USER/go \
    -i registry.fedoraproject.org/fedora-toolbox:42
```

### Can I use multiple toolboxes at once?

**Yes!** You can have multiple terminal windows, each in different toolboxes.

### What if I need Go on the host?

Ask yourself: *why?*

For development: Use distrobox
For scripting: Use distrobox or Bash
For system utilities: Consider if Go is the right choice

If you really need it, you can install via Homebrew:
```bash
brew install go
```

But the recommended approach is distrobox.

### How do I update Go?

```bash
# Enter the toolbox
distrobox enter go-dev

# Update Go
sudo dnf upgrade golang

# Or recreate the toolbox with latest Fedora
distrobox rm go-dev
ujust create-go-toolbox
```

## Recommended Setup

```bash
# 1. Deploy Hublue (Go removed from system)
# 2. Create Go toolbox
ujust create-go-toolbox

# 3. Add convenience alias
echo 'alias go-dev="distrobox enter go-dev"' >> ~/.zshrc

# 4. Develop!
go-dev
cd ~/Projects/myproject
go build
```

## Resources

- [Distrobox Documentation](https://distrobox.it/)
- [Universal Blue Guide](https://universal-blue.org/guide/toolbox/)
- [Go Installation Guide](https://go.dev/doc/install)
- [Fedora Toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/)

## Summary

**Remove Go from system level. Use distrobox instead.**

**Benefits:**
- ✅ Smaller base image (-280MB)
- ✅ Multiple Go versions
- ✅ Easy updates
- ✅ Project isolation
- ✅ Best practice for immutable OS
- ✅ More flexible

**One command to set up:**
```bash
ujust create-go-toolbox
```

**Enter and develop:**
```bash
distrobox enter go-dev
```

Done! 🎉
