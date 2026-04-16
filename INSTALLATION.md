# Hublue Installation Guide

## Quick Reference

**Current laptop (already running Hublue):**
```bash
git add . && git commit -m "Update" && git push
# Wait for GitHub Actions build to complete
ujust update && systemctl reboot
```

**New laptop from Bluefin/Bazzite:**
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:latest
systemctl reboot
```

---

## Installation Methods

### Method 1: Update Existing Hublue System (This Laptop)

You're already running Hublue! Just update to get the latest changes.

#### Step 1: Commit and Push Your Changes

```bash
cd ~/Projects/github.com/hubeadmin/hublue

# Add all your new files
git add .

# Commit your changes
git commit -m "Add ujust-picker, improved user-space management, Go in distrobox"

# Push to GitHub (triggers automatic build)
git push origin main
```

#### Step 2: Monitor the Build

1. Go to https://github.com/hubeadmin/hublue/actions
2. Click on the latest "Build Custom Image" workflow
3. Wait for it to complete (usually 5-10 minutes)
4. You'll see: ✅ Build and push image

#### Step 3: Update Your System

```bash
# Update to the latest image
ujust update

# Or manually
rpm-ostree update

# Check what will change
rpm-ostree status

# Reboot to apply
systemctl reboot
```

#### Step 4: First Time Setup (After Reboot)

```bash
# Try the new interactive picker!
ujust-picker

# Run complete user setup
ujust setup-user

# Create Go development environment
ujust create-go-toolbox
```

---

### Method 2: Rebase from Bluefin/Bazzite/Aurora (Existing Install)

If you have another laptop running Bluefin, Bazzite, or Aurora, you can switch to Hublue without reinstalling.

#### Prerequisites
- Laptop running Bluefin, Bazzite, Aurora, or any Universal Blue image
- Internet connection

#### Steps

1. **Rebase to Hublue:**
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:latest
   ```

2. **Wait for download** (this will download the entire image, ~3-5GB)

3. **Reboot:**
   ```bash
   systemctl reboot
   ```

4. **After reboot, verify:**
   ```bash
   rpm-ostree status
   # Should show: ghcr.io/hubeadmin/hublue:latest
   ```

5. **Run user setup:**
   ```bash
   ujust-picker    # Interactive TUI
   ujust setup-user # Complete setup
   ```

#### Reverting Back

If you want to go back to Bluefin:
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin-nvidia:stable
systemctl reboot
```

---

### Method 3: Fresh Install via ISO (New Machine or Clean Install)

Build a bootable ISO for a fresh installation.

#### Step 1: Update iso.toml

Already done! The file is configured with `ghcr.io/hubeadmin/hublue:latest`

#### Step 2: Trigger ISO Build

**Option A: Via GitHub Web UI**
1. Go to https://github.com/hubeadmin/hublue/actions
2. Click "Build ISOs" workflow
3. Click "Run workflow"
4. Select platform: `amd64`
5. Click "Run workflow"

**Option B: Via GitHub CLI**
```bash
gh workflow run build-iso.yml -f platform=amd64
```

#### Step 3: Download the ISO

After the workflow completes (~15-20 minutes):

1. Go to the workflow run
2. Scroll to "Artifacts" section
3. Download the ISO (or it will be in your S3 bucket if configured)

#### Step 4: Create Bootable USB

**On Linux:**
```bash
# Find your USB device
lsblk

# Write ISO to USB (replace /dev/sdX with your USB device)
sudo dd if=hublue.iso of=/dev/sdX bs=4M status=progress && sync
```

**On Windows:**
- Use [Rufus](https://rufus.ie/) or [Ventoy](https://www.ventoy.net/)

**On macOS:**
```bash
# Find your USB device
diskutil list

# Unmount the USB
diskutil unmountDisk /dev/diskX

# Write ISO
sudo dd if=hublue.iso of=/dev/rdiskX bs=1m
```

#### Step 5: Boot and Install

1. Insert USB into target laptop
2. Boot from USB (usually F12, F2, or Del during startup)
3. Follow the installation wizard
4. Reboot after installation

#### Step 6: First Boot Setup

```bash
# Launch interactive picker
ujust-picker

# Complete user setup
ujust setup-user

# Optional: Create Go development environment
ujust create-go-toolbox
```

---

### Method 4: Local Build and Deploy (Testing)

For testing changes locally before pushing to GitHub.

#### Build Locally

```bash
cd ~/Projects/github.com/hubeadmin/hublue

# Build with podman
podman build -t localhost/hublue:testing -f Containerfile .

# Or use the build script
./build-and-push.sh
```

#### Rebase to Local Image

```bash
# Rebase to your local build
rpm-ostree rebase ostree-unverified-registry:localhost/hublue:testing

# Reboot
systemctl reboot
```

#### Switch Back to Remote

```bash
# Switch back to the GitHub-built image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:latest
systemctl reboot
```

---

## Post-Installation Setup

After installing Hublue via any method, run these commands:

### Essential Setup

```bash
# 1. Interactive command picker (explore what's available)
ujust-picker

# 2. Complete user setup (Homebrew, tools, shell config)
ujust setup-user

# 3. Set zsh as default shell (optional)
ujust set-zsh-default
```

### Development Setup

```bash
# Create Go development environment
ujust create-go-toolbox

# Enter and test
distrobox enter go-dev
go version
exit
```

### Verify Installation

```bash
# Check system status
rpm-ostree status

# Check installed tools
which ujust-picker eza bat starship atuin

# List all available commands
ujust --list

# Check distrobox
distrobox list
```

---

## Automatic Updates

Hublue is configured to check for updates daily.

### Check for Updates Manually

```bash
# Update system image
ujust update

# Update user packages
ujust update-user

# Update all distroboxes
distrobox upgrade --all
```

### Disable Automatic Updates

```bash
# Disable automatic updates
sudo systemctl disable rpm-ostreed-automatic.timer

# Re-enable
sudo systemctl enable rpm-ostreed-automatic.timer
```

---

## Multiple Machines

### Scenario 1: Same Setup on All Machines

Use the same image on all machines:

```bash
# On each machine
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:latest
systemctl reboot
ujust setup-user
```

### Scenario 2: Machine-Specific Customizations

Use image tags for different configs:

```bash
# Build different tags in GitHub Actions
# Then on work laptop:
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:work

# On personal laptop:
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:personal
```

### Scenario 3: Sync Dotfiles Across Machines

Use chezmoi (already installed via Homebrew):

```bash
# On first machine
chezmoi init
chezmoi add ~/.zshrc ~/.bashrc
cd ~/.local/share/chezmoi
git init && git add . && git commit -m "Initial dotfiles"
git remote add origin git@github.com:yourusername/dotfiles.git
git push

# On other machines (after ujust setup-user)
chezmoi init --apply git@github.com:yourusername/dotfiles.git
```

---

## Verification

After installation, verify everything is working:

```bash
# Check system
rpm-ostree status | grep hublue

# Check ujust commands
ujust --list

# Check interactive picker
ujust-picker

# Check Homebrew (after setup-user)
brew --version

# Check shell enhancements
starship --version
atuin --version
eza --version

# Check distrobox
distrobox list
```

---

## Troubleshooting

### Build Failed on GitHub Actions

1. Check the workflow logs at https://github.com/hubeadmin/hublue/actions
2. Common issues:
   - Network timeout downloading packages
   - COPR repository temporarily unavailable
   - Syntax error in build.sh

**Solution:** Re-run the workflow or fix the error and push again

### Rebase Failed

```bash
# Check current status
rpm-ostree status

# Cancel any pending deployment
rpm-ostree cancel

# Try again
rpm-ostree rebase ostree-unverified-registry:ghcr.io/hubeadmin/hublue:latest
```

### Stuck on Old Image

```bash
# Force check for updates
rpm-ostree update --check

# Force download
rpm-ostree update --preview

# Apply update
rpm-ostree update
systemctl reboot
```

### ujust-picker Not Found

The tool is only available after you've built and deployed the updated image with the changes we just made.

**Current system:**
```bash
rpm-ostree status
# Check the timestamp - if it's older than your latest build, update
```

**Update to latest:**
```bash
rpm-ostree update
systemctl reboot
```

### Homebrew Installation Failed

```bash
# Run setup again (it's idempotent)
ujust setup-user

# Or install Homebrew manually
ujust install-brew
```

---

## Next Steps

After successful installation:

1. **Read the documentation:**
   - [USER-SETUP.md](USER-SETUP.md) - Complete setup guide
   - [CHEATSHEET.md](CHEATSHEET.md) - Quick command reference
   - [GO-DEVELOPMENT.md](GO-DEVELOPMENT.md) - Go development workflow

2. **Customize your setup:**
   - Edit Brewfile: `cp /usr/share/hublue/Brewfile ~/Brewfile`
   - Add custom ujust commands: Edit `/usr/share/ublue-os/just/60-hublue.just`
   - Configure shell: Edit `~/.zshrc` or `~/.bashrc`

3. **Create development environments:**
   ```bash
   ujust create-go-toolbox
   ujust create-dev-toolbox myproject
   ```

4. **Keep your system updated:**
   ```bash
   ujust update        # System
   ujust update-user   # User packages
   ```

---

## Support

- **GitHub Issues:** https://github.com/hubeadmin/hublue/issues
- **Universal Blue Docs:** https://universal-blue.org/
- **Bluefin Docs:** https://projectbluefin.io/

Enjoy your Hublue system! 🎉
