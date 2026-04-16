# Secure Boot Guide for Hublue

## Current Status
Your image is **fully compatible** with Secure Boot because:
- Base image (bluefin-nvidia) is signed and Secure Boot ready
- NVIDIA drivers are signed with Microsoft UEFI keys
- Build script only installs userspace packages
- Images are signed with cosign

## Enabling Secure Boot

### 1. Enter UEFI/BIOS Settings
- Reboot your computer
- Press the appropriate key during boot (usually F2, F10, F12, Del, or Esc)
- Look for "UEFI Firmware Settings" or similar

### 2. Enable Secure Boot
Navigate to:
- **Security** → **Secure Boot** → **Enabled**
- Or: **Boot** → **Secure Boot** → **Enabled**

### 3. Set Secure Boot Mode
- Choose **Microsoft UEFI CA** or **Standard** mode (NOT "Custom")
- This ensures the NVIDIA drivers will be recognized

### 4. Clear/Reset Keys (if needed)
- If you had custom keys, reset to factory defaults
- Option usually called "Restore Factory Keys" or "Clear Secure Boot Keys"

### 5. Save and Reboot
- Save settings (usually F10)
- System will reboot

### 6. Verify Secure Boot is Active
After boot, run:
```bash
mokutil --sb-state
# Should show: SecureBoot enabled
```

Or:
```bash
bootctl status | grep "Secure Boot"
# Should show: Secure Boot: enabled (user)
```

## Maintaining Secure Boot Compatibility

### ✅ Safe to Do (Won't Break Secure Boot)
- Install packages via DNF/Homebrew
- Install flatpaks
- Run containers (Podman/Docker)
- Update the base image
- Add configuration files
- Install Go, Rust, Node.js, etc.

### ❌ Will Break Secure Boot
- Installing unsigned kernel modules
- Building custom kernel drivers
- Using third-party kernel modules not signed by Microsoft
- Installing VirtualBox (use libvirt/KVM instead - already in your build!)

## Verifying Your Image Works with Secure Boot

### Check Image Signature
```bash
# Verify the cosign signature
cosign verify \
  --key cosign.pub \
  ghcr.io/hubeadmin/hublue:latest
```

### Check Base Image
```bash
# Verify the base image is signed
rpm-ostree status
```

## If Secure Boot Fails to Enable

### Common Issues:

1. **"Validation Failed" on Boot**
   - Reset Secure Boot keys to factory defaults
   - Make sure you're using "Microsoft UEFI CA" mode

2. **NVIDIA Driver Issues**
   - The bluefin-nvidia base already has signed NVIDIA drivers
   - Don't manually install NVIDIA drivers

3. **Can't Find Secure Boot in BIOS**
   - Some systems require setting a BIOS/supervisor password first
   - Disable Legacy/CSM mode - use UEFI only

4. **Custom Hardware**
   - Some motherboards have Secure Boot hidden/disabled in consumer mode
   - Check if there's a "Windows Mode" or "Other OS" setting

## Testing After Enabling Secure Boot

1. Enable Secure Boot in BIOS
2. Reboot to your hublue image
3. Run verification:
```bash
# Check Secure Boot status
mokutil --sb-state

# Check kernel is signed
dmesg | grep -i "secure boot"

# Check NVIDIA drivers loaded
nvidia-smi

# Verify ostree status
rpm-ostree status
```

## Additional Security

Your image is already signed with cosign. To verify future updates:

```bash
# Add your public key to the system
sudo cp cosign.pub /etc/pki/containers/

# Configure podman to verify signatures
sudo mkdir -p /etc/containers/registries.d/
sudo tee /etc/containers/registries.d/ghcr.io-hubeadmin.yaml <<EOF
docker:
  ghcr.io/hubeadmin:
    use-sigstore-attachments: true
EOF
```

## Resources
- [Universal Blue Secure Boot Guide](https://universal-blue.org/guide/secure-boot/)
- [Fedora Secure Boot Documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/#_secure_boot)
- [NVIDIA Driver Signing](https://github.com/ublue-os/nvidia)
