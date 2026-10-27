# surface-pro-7-cachyos

Installs the [linux-surface](https://github.com/linux-surface/linux-surface) kernel, headers, and `iptsd` (touch and pen daemon) on a Surface Pro 7 running CachyOS.

```
curl -fsSL https://raw.githubusercontent.com/School-User/surface-pro-7-cachyos/main/install-surface-kernel.sh -o install-surface-kernel.sh
bash install-surface-kernel.sh
```

Run as your normal user, not root. The script uses sudo where needed.

Before you run it:
- Secure Boot must be off. The linux-surface kernel is not signed for it.
- Keep the stock CachyOS kernel entry in the boot menu as a fallback.
- Check the signing key fingerprint (`56C464BAAC421453`) and repo URL against the [linux-surface package repositories wiki](https://github.com/linux-surface/linux-surface/wiki/Package-Repositories).

Installed by the kernel package: touch, pen, keyboard, and battery drivers. Not covered by this script: camera (not verified), audio config, and userspace tools such as `libwacom-surface`.

Not tested on this hardware yet.
