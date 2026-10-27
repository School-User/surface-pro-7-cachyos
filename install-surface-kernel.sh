#!/usr/bin/env bash
# Install the linux-surface kernel + touch/pen daemon on a Surface Pro 7 running CachyOS (Arch-based).
# Run as your normal user; the script calls sudo where needed.
set -euo pipefail

KEY_URL="https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc"
KEY_FPR="56C464BAAC421453"
REPO_URL="https://pkg.surfacelinux.com/arch/"

if [[ $EUID -eq 0 ]]; then
    echo "Run as your normal user, not root." >&2
    exit 1
fi

if ! command -v pacman >/dev/null; then
    echo "pacman not found; this script is for Arch-based systems." >&2
    exit 1
fi

if ! grep -qi 'surface' /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null; then
    echo "Warning: DMI vendor is not Microsoft/Surface. Continuing anyway." >&2
fi

# 1. Add the linux-surface repo (once).
if ! grep -q '^\[linux-surface\]' /etc/pacman.conf; then
    echo "Adding [linux-surface] repo to /etc/pacman.conf"
    printf '\n[linux-surface]\nServer = %s\n' "$REPO_URL" | sudo tee -a /etc/pacman.conf >/dev/null
fi

# 2. Import and locally sign the repo key (once).
if ! sudo pacman-key --list-keys "$KEY_FPR" >/dev/null 2>&1; then
    echo "Importing linux-surface signing key"
    curl -fsSL "$KEY_URL" | sudo pacman-key --add -
    sudo pacman-key --finger "$KEY_FPR"
    sudo pacman-key --lsign-key "$KEY_FPR"
fi

# 3. Sync and install kernel, headers, and the iptsd touch/pen daemon.
sudo pacman -Syu --needed linux-surface linux-surface-headers iptsd

# 4. Rebuild initramfs and boot entries if the hooks did not already do it.
if command -v mkinitcpio >/dev/null; then
    sudo mkinitcpio -P
fi
if command -v limine-update >/dev/null; then
    sudo limine-update
fi

# 5. Enable touch/pen support.
sudo systemctl enable --now iptsd

echo
echo "Done. Reboot and pick the linux-surface entry in the boot menu."
echo "Keep the stock CachyOS kernel entry as a fallback until touch and Wi-Fi are confirmed."
echo "Secure Boot must be off (linux-surface kernels are not signed for it)."
