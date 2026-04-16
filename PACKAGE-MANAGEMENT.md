# Package Management in Hublue

## TL;DR

**By default: Append-only (safe)**
- `ujust install-brew-packages` - Installs packages from Brewfile
- **Does NOT remove** packages you delete from Brewfile

**To clean up removed packages:**
```bash
ujust brew-cleanup-preview    # See what would be removed
ujust sync-brew-packages       # Actually remove unlisted packages
```

---

## How It Works

### System Packages (Immutable)
Defined in: `build_files/build.sh`

- Built into the image at build time
- Changes require rebuilding the image
- Automatically removed if you remove them and rebuild

### User Packages (Mutable)
Defined in: `build_files/Brewfile`

- Installed after first boot via Homebrew
- **Append-only by default** - won't remove packages
- Optional cleanup with `ujust sync-brew-packages`

---

## Examples

### Adding a Package

Edit Brewfile:
```ruby
brew "eza"
brew "bat"
brew "new-tool"  # Add this
```

Install it:
```bash
ujust install-brew-packages  # Or just: brew install new-tool
```

### Removing a Package (Default Behavior)

Edit Brewfile:
```ruby
brew "eza"
brew "bat"
# Removed "old-tool" from list
```

Run install:
```bash
ujust install-brew-packages
```

**Result:** `old-tool` is STILL installed (not removed automatically)

### Removing a Package (With Cleanup)

After removing from Brewfile:

```bash
# Preview what would be removed
ujust brew-cleanup-preview

# Actually remove it
ujust sync-brew-packages
```

**Result:** `old-tool` is now removed

---

## Commands

```bash
# Install packages (append-only)
ujust install-brew-packages

# Preview cleanup
ujust brew-cleanup-preview

# Sync with Brewfile (removes unlisted)
ujust sync-brew-packages

# Update packages
ujust update-user
```

---

## Workflows

### Safe & Flexible (Recommended)
```bash
# Install baseline from Brewfile
ujust install-brew-packages

# Install extras manually as needed
brew install experimental-tool

# Periodically check for cruft
ujust brew-cleanup-preview
```

### Strict & Declarative
```bash
# Edit Brewfile in repo, commit, push, rebuild

# After system update, sync packages
ujust sync-brew-packages

# Result: System matches Brewfile exactly
```

---

## Best Practices

✅ **Do:**
- Use Brewfile for common tools
- Run `brew-cleanup-preview` before `sync-brew-packages`
- Version control your Brewfile
- Add comments to Brewfile

❌ **Don't:**
- Run `sync-brew-packages` blindly (check preview first!)
- Mix system packages (DNF) with user packages (Homebrew)

---

## FAQ

**Q: Why not auto-remove packages?**
A: Safety. Auto-removal could break your workflow if you manually installed packages.

**Q: What happens if I manually `brew install` a package?**
A: It stays installed. `sync-brew-packages` will remove it unless you add it to Brewfile.

**Q: Should I run `sync-brew-packages` after every update?**
A: No, only when you want to clean up packages removed from Brewfile.

---

## Summary

| Command | What it does |
|---------|-------------|
| `ujust install-brew-packages` | Installs packages from Brewfile (safe, append-only) |
| `ujust brew-cleanup-preview` | Shows what would be removed |
| `ujust sync-brew-packages` | Removes packages NOT in Brewfile |
| `ujust update-user` | Updates all Homebrew packages |

**Default philosophy:** Safe and flexible (append-only)
**Optional:** Strict and declarative (with sync)
