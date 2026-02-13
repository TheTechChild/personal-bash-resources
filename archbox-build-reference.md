# Archbox Build Reference

**System:** archbox  
**Built:** January 31 â€“ February 1, 2026  
**OS:** Arch Linux with Hyprland  
**Inspired by:** Chris Titus Tech's minimal gaming setup  

---

## Hardware

| Component | Details |
|-----------|---------|
| CPU | AMD Ryzen 9 5900X (12C/24T, no iGPU) |
| GPU | AMD Radeon RX 7900 XT (Navi 31, amdgpu driver) |
| RAM | 32 GB |
| NVMe 1 | 1 TB â€” Arch Linux (Btrfs) â€” `/dev/nvme0n1` |
| NVMe 2 | NTFS â€” GameVault â€” `/dev/nvme1n1p1` |
| NVMe 3 | NTFS â€” GameVault2 â€” `/dev/nvme2n1p1` |
| WiFi | 5 GHz (TheNoisyNetwork5, channel 149) |
| Mic | Blue Yeti USB (vendor 046d, product 0ab7) |
| Webcam | Logitech C925e (backup mic) |
| Audio Out | DisplayPort audio via Navi 31 HDMI/DP |
| Monitor 1 | ASUS 2560Ã—1440 @ 165 Hz (DP-1, main, landscape) |
| Monitor 2 | LG 3840Ã—2160 (DP-3, portrait mode, scaled to 2560Ã—1440) |

---

## Partition Layout (nvme0n1)

```
nvme0n1p1  â€” EFI System Partition â€” /boot (FAT32)
nvme0n1p2  â€” Arch Linux root (Btrfs)
```

### Btrfs Subvolumes

| Subvolume | Mount Point | Purpose |
|-----------|-------------|---------|
| @ | / | Root filesystem |
| @home | /home | User data |
| @log | /var/log | System logs |
| @cache | /var/cache | Package cache |
| @snapshots | /.snapshots | Snapper snapshots |

**Bootloader:** GRUB with grub-btrfs for snapshot booting

---

## Key Configuration Files

### Hyprland
- **Main config:** `~/.config/hypr/hyprland.conf`
- **Startup script:** `start-hyprland` (wrapper, launched from `~/.bash_profile`)

### Monitor Configuration (in hyprland.conf)
```
monitor = DP-1, 2560x1440@165, 0x0, 1
monitor = DP-3, 3840x2160, -1440x-560, 1, transform, 1
```
- DP-1 (ASUS): Main display at origin
- DP-3 (LG): Portrait mode (transform,1), positioned left of main, offset -560px vertically

### Keybindings (in hyprland.conf)
| Key | Action |
|-----|--------|
| Super + Return | foot terminal |
| Super + D | Wofi app launcher |
| Super + Arrow | Move focus |
| Super + 1-9 | Switch workspace |
| Super + Shift + 1-9 | Move window to workspace |
| Super + Shift + < / > | Move window between monitors |
| Super + < / > | Focus other monitor |
| Super + Shift + Arrow | Move window directionally |
| Print | Screenshot (selection with slurp) |
| Shift + Print | Screenshot (full screen) |

### Desktop Environment
- **Status bar:** Waybar
- **App launcher:** Wofi
- **Terminal:** foot
- **File manager:** Thunar
- **Wallpaper:** swww (exec-once in hyprland.conf, set to solid black via `swww clear 000000`)

### GTK Dark Theme
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`

```ini
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
```

### Screenshots
- **Scripts:** `~/Pictures/Screenshots/screenshot.sh` and `screenshot-full.sh`
- **Output:** `~/Pictures/Screenshots/YYYYMMDD_HHMMSS.png`
- **Tools:** grim (capture) + slurp (selection)

### Claude Desktop Scaling Fix
- `~/.local/share/applications/claude-desktop.desktop`
- Exec line: `claude --force-device-scale-factor=1 %U`

---

## Storage Mounts

### Game Drives (/etc/fstab)

```
UUID=1EAE64BBAE648D59  /mnt/GameVault   ntfs-3g  defaults,uid=1000,gid=1000,umask=000  0 0
UUID=849AB7AD9AB799DE  /mnt/GameVault2  ntfs-3g  defaults,uid=1000,gid=1000,umask=000  0 0
```

**Contents of GameVault:**
- SteamLibrary
- Modded XWA (X-Wing Alliance)
- GOG games
- Blizzard
- Minecraft
- NexusMods / SatisfactoryMods
- Skyrim Special Edition
- GBA ROMs
- Shared Books

**Contents of GameVault2:**
- SteamLibrary

### NAS Shares (Systemd Automount)

**NAS:** Unraid server at `192.168.1.152` (tower.local)  
**Credentials:** `/etc/samba/credentials` (chmod 600)

```
username=<unraid_username>
password=<unraid_password>
```

**Working mount/automount unit pairs in `/etc/systemd/system/`:**

| Share | Mount Point | Unit Files | Notes |
|-------|-------------|------------|-------|
| Media | /mnt/nas/media | mnt-nas-media.mount / .automount | |
| Photos | /mnt/nas/photos | mnt-nas-photos.mount / .automount | |
| Backups | /mnt/nas/backups | mnt-nas-backups.mount / .automount | |
| Clayton - Data | /mnt/nas/clayton_data | mnt-nas-clayton\_data.mount / .automount | Requires `vers=3.0` in mount options |

**Mount unit template:**
```ini
[Unit]
Description=NAS <Share> Share
After=network-online.target
Wants=network-online.target

[Mount]
What=//192.168.1.152/<Share>
Where=/mnt/nas/<share>
Type=cifs
Options=credentials=/etc/samba/credentials,uid=1000,gid=1000,_netdev

[Install]
WantedBy=multi-user.target
```

**Automount unit template:**
```ini
[Unit]
Description=Automount NAS <Share> Share

[Automount]
Where=/mnt/nas/<share>
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target
```

**Enable with:** `sudo systemctl enable --now mnt-nas-<share>.automount`

### Clayton - Data Share Fix

The `Clayton - Data` share has spaces in its name, which caused `mount.cifs` to fail with "cannot mount read-only" errors. The root cause was an SMB protocol version negotiation issue — the fix was adding `vers=3.0` to the mount options. The share name with spaces works fine in the `What=` line without escaping.

**Mount unit:** `/etc/systemd/system/mnt-nas-clayton_data.mount`
```ini
[Unit]
Description=NAS Clayton-Data Share
After=network-online.target
Wants=network-online.target

[Mount]
What=//192.168.1.152/Clayton - Data
Where=/mnt/nas/clayton_data
Type=cifs
Options=credentials=/etc/samba/credentials,uid=1000,gid=1000,_netdev,vers=3.0

[Install]
WantedBy=multi-user.target
```

**Diagnostic tool:** `smbclient` (installed via `pacman -S smbclient`) — useful for listing and testing NAS shares:
```bash
sudo smbclient -L //192.168.1.152 -A /etc/samba/credentials   # List shares
sudo smbclient "//192.168.1.152/Clayton - Data" -A /etc/samba/credentials  # Connect interactively
```

---

## Audio Configuration

- **Stack:** PipeWire with WirePlumber
- **Output:** Navi 31 HDMI/DP (wpctl set-default 34)
- **Input:** Blue Yeti (wpctl set-default 65)
- **GUI:** pavucontrol
- **CLI:** wpctl, pw-play, arecord

### Blue Yeti USB Autosuspend Fix

The Blue Yeti gets I/O errors from USB autosuspend. Fixed with a udev rule:

**File:** `/etc/udev/rules.d/50-usb-autosuspend.rules`
```
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0ab7", ATTR{power/autosuspend}="-1"
```

**Manual override (temporary):**
```bash
echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend
```

---

## Network Configuration

- **WiFi:** NetworkManager, connected to TheNoisyNetwork5 (5 GHz)
- **Speed:** ~212 Mbit/s down, ~85 Mbit/s up
- **mDNS:** avahi-daemon enabled for `.local` resolution

### /etc/nsswitch.conf (hosts line)
```
hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
```

---

## Enabled Systemd Services

| Service | Purpose |
|---------|---------|
| NetworkManager | WiFi/network management |
| fstrim.timer | Periodic SSD TRIM |
| avahi-daemon | mDNS / .local resolution |
| mnt-nas-media.automount | NAS Media on-demand mount |
| mnt-nas-photos.automount | NAS Photos on-demand mount |
| mnt-nas-backups.automount | NAS Backups on-demand mount |
| mnt-nas-clayton_data.automount | NAS Clayton-Data on-demand mount |

---

## Gaming Setup

- **Steam:** Installed, libraries at `/mnt/GameVault/SteamLibrary` and `/mnt/GameVault2/SteamLibrary`
- **AUR helper:** paru
- **Proton:** Native Steam Proton (Proton-GE pending via protonup-qt)
- **Locale:** en_US.UTF-8 (fixed for Steam)

---

## Personal Bash Resources

**Repo:** https://github.com/TheTechChild/personal-bash-resources

Modular framework with platform detection (macOS/Arch). Key Arch gaming modules in `modules/arch/gaming.sh`:
- `arch-setup-base` â€” Core system packages
- `arch-setup-shell` â€” Shell environment (zsh, starship)
- `arch-setup-desktop` â€” Hyprland/DWM desktop
- `arch-setup-gaming` â€” Gaming tools (Steam, Proton, etc.)
- `arch-setup-vm` â€” VM passthrough setup (VFIO)
- `arch-setup-apps` â€” Applications
- `arch-setup-all` â€” Run everything

Includes encrypted backup system with manifest for SSH keys/configs.

---

## Backup

**Original Windows system** backed up via Clonezilla to Unraid NAS before Arch installation. Full disk image preserved.

---

## Pending / Unresolved

### ðŸŽ® Proton-GE
Run `protonup-qt` to download Proton-GE for better game compatibility.

### ðŸ”‘ Bitwarden
```bash
paru -S bitwarden
```

### âœˆï¸ X-Wing Alliance VM (Single-GPU Passthrough)
Full VM passthrough setup still needed for X-Wing Alliance with HOTAS:
1. Run `arch-setup-vm` from personal-bash-resources
2. Configure VFIO kernel parameters for single-GPU passthrough
3. Dump 7900 XT GPU ROM (may need to disable Resizable BAR in BIOS)
4. Set up libvirt/QEMU Windows VM
5. Configure USB passthrough for HOTAS (flight stick + throttle)
6. Install xwaupgrade (https://xwaupgrade.com/) in VM
7. This is the only game requiring a VM â€” everything else runs via Proton

### ðŸŒ NAS IP Stability
Currently using DHCP IP `192.168.1.152` for the NAS. Consider setting a DHCP reservation on the router or a static IP on Unraid for reliability.

### ðŸŽ® Test Gaming
Test Steam library games under Proton to verify everything works.

---

## Quick Reference Commands

```bash
# Restart Hyprland (reload config)
hyprctl reload

# Check monitor setup
hyprctl monitors

# Audio defaults
wpctl set-default 34    # Output (Navi 31)
wpctl set-default 65    # Input (Blue Yeti)
wpctl status            # Show all audio devices

# Mount NAS shares manually
sudo systemctl start mnt-nas-media.mount

# Check NAS mount status
systemctl status mnt-nas-media.automount

# WiFi
nmcli device wifi list
nmcli device wifi connect "TheNoisyNetwork5" password "..."

# Speed test
speedtest-cli

# Screenshot
grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png

# System update
sudo pacman -Syu
paru -Syu

# Btrfs snapshot (via snapper)
sudo snapper create --description "pre-update"
```
