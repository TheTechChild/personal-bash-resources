#!/bin/bash
# ============= Arch Linux Gaming System Setup =============
# Chris Titus Tech-inspired Arch Linux setup for gaming desktops.
# Provides phased installation: base, shell, desktop (Hyprland or DWM), gaming, VM passthrough.
#
# Usage: Run individual phases or arch-setup-all for guided full setup.
#   arch-setup-base             - Foundation (paru, snapper, base-devel)
#   arch-setup-shell            - Shell environment (zsh, starship, CTT mybash)
#   arch-setup-desktop-hyprland - Wayland gaming desktop
#   arch-setup-desktop-dwm      - X11 DWM desktop (CTT fork)
#   arch-setup-gaming           - Steam, AMD drivers, Lutris, MangoHud
#   arch-setup-vm               - QEMU/KVM single-GPU passthrough prep
#   arch-setup-all              - Guided full setup

# ---------------------------------------------------------------------------
# Helper functions (prefixed with underscore — not intended for direct use)
# ---------------------------------------------------------------------------

_arch_print_header() {
    echo ""
    echo "================================================================"
    echo "  $1"
    echo "================================================================"
    echo ""
}

_arch_print_step() {
    echo ">>> $1"
}

_arch_check_aur_helper() {
    if command -v paru &>/dev/null; then
        echo "paru"
    elif command -v yay &>/dev/null; then
        echo "yay"
    else
        echo ""
    fi
}

_arch_install_packages() {
    local helper
    helper=$(_arch_check_aur_helper)
    if [[ -n "$helper" ]]; then
        "$helper" -S --needed --noconfirm "$@"
    else
        sudo pacman -S --needed --noconfirm "$@"
    fi
}

_arch_install_aur_packages() {
    local helper
    helper=$(_arch_check_aur_helper)
    if [[ -z "$helper" ]]; then
        echo "ERROR: No AUR helper (paru/yay) found. Run arch-setup-base first."
        return 1
    fi
    "$helper" -S --needed --noconfirm "$@"
}

# ---------------------------------------------------------------------------
# Phase: Base
# ---------------------------------------------------------------------------

arch-setup-base() {
    _arch_print_header "Phase: Base System Setup"

    _arch_print_step "Installing base-devel and git"
    sudo pacman -S --needed --noconfirm base-devel git

    if ! command -v paru &>/dev/null; then
        _arch_print_step "Building and installing paru"
        local paru_tmp
        paru_tmp=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$paru_tmp/paru"
        (cd "$paru_tmp/paru" && makepkg -si --noconfirm)
        rm -rf "$paru_tmp"
    else
        _arch_print_step "paru already installed — skipping"
    fi

    _arch_print_step "Installing Btrfs snapshot tools (snapper, snap-pac, grub-btrfs)"
    _arch_install_packages snapper snap-pac grub-btrfs

    if findmnt -n -o FSTYPE / | grep -q btrfs; then
        if [[ ! -f /etc/snapper/configs/root ]]; then
            _arch_print_step "Creating snapper config for root subvolume"
            sudo snapper -c root create-config /
        else
            _arch_print_step "Snapper root config already exists — skipping creation"
        fi

        _arch_print_step "Setting snapshot retention limits"
        sudo snapper -c root set-config \
            "TIMELINE_MIN_AGE=1800" \
            "TIMELINE_LIMIT_HOURLY=5" \
            "TIMELINE_LIMIT_DAILY=7" \
            "TIMELINE_LIMIT_WEEKLY=2" \
            "TIMELINE_LIMIT_MONTHLY=1" \
            "TIMELINE_LIMIT_YEARLY=0"

        _arch_print_step "Enabling snapper timers and grub-btrfsd"
        sudo systemctl enable --now snapper-timeline.timer
        sudo systemctl enable --now snapper-cleanup.timer
        sudo systemctl enable --now grub-btrfsd
    else
        _arch_print_step "Root filesystem is not Btrfs — skipping snapper configuration"
    fi

    _arch_print_step "Installing informant (AUR) and topgrade"
    _arch_install_aur_packages informant
    _arch_install_packages topgrade

    _arch_print_header "Base Setup Complete"
    echo "Installed: base-devel, git, paru, snapper, snap-pac, grub-btrfs, informant, topgrade"
    echo ""
    echo "Manual steps:"
    echo "  - Review snapper config:  sudo snapper -c root get-config"
    echo "  - Read informant notices: sudo informant read"
}

# ---------------------------------------------------------------------------
# Phase: Shell Environment
# ---------------------------------------------------------------------------

arch-setup-shell() {
    _arch_print_header "Phase: Shell Environment (Chris Titus Tech style)"

    _arch_print_step "Installing shell tools"
    _arch_install_packages \
        zsh starship zoxide fzf bat eza ripgrep fd fastfetch

    _arch_print_step "Installing Nerd Fonts"
    _arch_install_packages ttf-jetbrains-mono-nerd ttf-firacode-nerd

    local mybash_dir="$HOME/.config/mybash"
    if [[ ! -d "$mybash_dir" ]]; then
        _arch_print_step "Cloning ChrisTitusTech/mybash"
        git clone https://github.com/ChrisTitusTech/mybash.git "$mybash_dir"
        if [[ -f "$mybash_dir/setup.sh" ]]; then
            _arch_print_step "Running mybash setup.sh"
            (cd "$mybash_dir" && bash setup.sh)
        fi
    else
        _arch_print_step "mybash already cloned at $mybash_dir — skipping"
    fi

    _arch_print_step "Installing Chris Titus Tech's linutil"
    curl -fsSL https://christitus.com/linux | sh

    local starship_config="$HOME/.config/starship.toml"
    if [[ ! -f "$starship_config" ]]; then
        _arch_print_step "Generating starship nerd-font-symbols preset"
        mkdir -p "$(dirname "$starship_config")"
        starship preset nerd-font-symbols -o "$starship_config"
    else
        _arch_print_step "Starship config already exists at $starship_config — skipping"
    fi

    _arch_print_header "Shell Setup Complete"
    echo "Installed: zsh, starship, zoxide, fzf, bat, eza, ripgrep, fd, fastfetch"
    echo "Installed: JetBrains Mono Nerd Font, FiraCode Nerd Font"
    echo "Cloned:    ChrisTitusTech/mybash -> $mybash_dir"
    echo ""
    echo "Manual steps:"
    echo "  - Change default shell:  chsh -s \$(which zsh)"
    echo "  - Customize starship:    $starship_config"
}

# ---------------------------------------------------------------------------
# Phase: Desktop — Hyprland (Wayland)
# ---------------------------------------------------------------------------

arch-setup-desktop-hyprland() {
    _arch_print_header "Phase: Hyprland Wayland Gaming Desktop"

    _arch_print_step "Installing Hyprland and Wayland ecosystem"
    _arch_install_packages \
        hyprland xdg-desktop-portal-hyprland \
        waybar wofi foot mako \
        grim slurp wl-clipboard \
        polkit-kde-agent qt5-wayland qt6-wayland \
        pipewire pipewire-pulse wireplumber pavucontrol \
        brightnessctl playerctl \
        networkmanager network-manager-applet \
        bluez bluez-utils blueman \
        thunar gvfs

    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    if [[ ! -f "$hypr_conf" ]]; then
        _arch_print_step "Writing Hyprland config with gaming optimizations"
        mkdir -p "$(dirname "$hypr_conf")"
        cat > "$hypr_conf" << 'HYPRCONF'
# Hyprland config — gaming-optimized
# Generated by personal-bash-resources

# ── Monitor ──────────────────────────────────────────────
monitor = , preferred, auto, 1

# ── Environment (AMD) ───────────────────────────────────
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_DRM_NO_ATOMIC,1
env = LIBVA_DRIVER_NAME,radeonsi
env = __GLX_VENDOR_LIBRARY_NAME,mesa
env = MOZ_ENABLE_WAYLAND,1
env = QT_QPA_PLATFORM,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland

# ── Input ────────────────────────────────────────────────
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    accel_profile = flat
}

# ── General ──────────────────────────────────────────────
general {
    gaps_in = 4
    gaps_out = 8
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# ── Performance (gaming) ─────────────────────────────────
decoration {
    rounding = 0
    blur {
        enabled = false
    }
    shadow {
        enabled = false
    }
}

animations {
    enabled = false
}

misc {
    vrr = 1
    no_direct_scanout = false
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
}

dwindle {
    pseudotile = true
    preserve_split = true
}

# ── Window rules (Steam / games fullscreen) ──────────────
windowrulev2 = fullscreen, class:^(steam_app_.*)$
windowrulev2 = immediate, class:^(steam_app_.*)$
windowrulev2 = fullscreen, class:^(gamescope)$
windowrulev2 = immediate, class:^(gamescope)$

# ── Autostart ────────────────────────────────────────────
exec-once = waybar
exec-once = mako
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = blueman-applet

# ── Keybindings ──────────────────────────────────────────
$mod = SUPER

bind = $mod, Return, exec, foot
bind = $mod, D, exec, wofi --show drun
bind = $mod, Q, killactive
bind = $mod SHIFT, E, exit
bind = $mod, V, togglefloating
bind = $mod, F, fullscreen
bind = $mod, P, pseudo
bind = $mod, J, togglesplit

bind = $mod, left, movefocus, l
bind = $mod, right, movefocus, r
bind = $mod, up, movefocus, u
bind = $mod, down, movefocus, d

bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5
bind = $mod, 6, workspace, 6
bind = $mod, 7, workspace, 7
bind = $mod, 8, workspace, 8
bind = $mod, 9, workspace, 9
bind = $mod, 0, workspace, 10

bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5
bind = $mod SHIFT, 6, movetoworkspace, 6
bind = $mod SHIFT, 7, movetoworkspace, 7
bind = $mod SHIFT, 8, movetoworkspace, 8
bind = $mod SHIFT, 9, movetoworkspace, 9
bind = $mod SHIFT, 0, movetoworkspace, 10

bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind  = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

binde = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

bindm = $mod, mouse:272, movewindow
bindm = $mod, mouse:273, resizewindow
HYPRCONF
    else
        _arch_print_step "Hyprland config already exists at $hypr_conf — skipping"
    fi

    _arch_print_step "Enabling NetworkManager, Bluetooth, and PipeWire services"
    sudo systemctl enable --now NetworkManager
    sudo systemctl enable --now bluetooth
    systemctl --user enable --now pipewire pipewire-pulse wireplumber

    local bash_profile="$HOME/.bash_profile"
    if ! grep -q 'exec Hyprland' "$bash_profile" 2>/dev/null; then
        _arch_print_step "Adding Hyprland auto-start to $bash_profile (TTY1)"
        cat >> "$bash_profile" << 'EOF'

# Auto-start Hyprland on TTY1
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    exec Hyprland
fi
EOF
    else
        _arch_print_step "Hyprland auto-start already in $bash_profile — skipping"
    fi

    _arch_print_header "Hyprland Desktop Setup Complete"
    echo "Installed: Hyprland, Waybar, Wofi, Foot, Mako, PipeWire, Bluetooth, Thunar"
    echo "Config:    $hypr_conf"
    echo ""
    echo "Manual steps:"
    echo "  - Customize Waybar:    ~/.config/waybar/config"
    echo "  - Reboot or log out to TTY1 and Hyprland will launch automatically"
}

# ---------------------------------------------------------------------------
# Phase: Desktop — DWM (X11, Chris Titus Tech fork)
# ---------------------------------------------------------------------------

arch-setup-desktop-dwm() {
    _arch_print_header "Phase: DWM Desktop (Chris Titus Tech fork)"

    _arch_print_step "Installing Xorg and DWM dependencies"
    _arch_install_packages \
        xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
        libx11 libxft libxinerama \
        picom feh dunst dmenu alacritty \
        pipewire pipewire-pulse wireplumber pavucontrol \
        networkmanager network-manager-applet \
        polkit-gnome thunar gvfs

    local dwm_dir="$HOME/.config/dwm-titus"
    if [[ ! -d "$dwm_dir" ]]; then
        _arch_print_step "Cloning ChrisTitusTech/dwm-titus"
        git clone https://github.com/ChrisTitusTech/dwm-titus.git "$dwm_dir"
        _arch_print_step "Building and installing DWM"
        (cd "$dwm_dir" && sudo make clean install)
    else
        _arch_print_step "dwm-titus already cloned at $dwm_dir — skipping"
    fi

    local xinitrc="$HOME/.xinitrc"
    if [[ ! -f "$xinitrc" ]]; then
        _arch_print_step "Creating $xinitrc"
        cat > "$xinitrc" << 'XINITRC'
#!/bin/sh
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
picom --daemon
dunst &
nm-applet &

exec dwm
XINITRC
        chmod +x "$xinitrc"
    else
        _arch_print_step ".xinitrc already exists — skipping"
    fi

    _arch_print_step "Enabling NetworkManager and PipeWire services"
    sudo systemctl enable --now NetworkManager
    systemctl --user enable --now pipewire pipewire-pulse wireplumber

    local bash_profile="$HOME/.bash_profile"
    if ! grep -q 'exec startx' "$bash_profile" 2>/dev/null; then
        _arch_print_step "Adding startx auto-start to $bash_profile (TTY1)"
        cat >> "$bash_profile" << 'EOF'

# Auto-start X on TTY1
if [[ -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    exec startx
fi
EOF
    else
        _arch_print_step "startx auto-start already in $bash_profile — skipping"
    fi

    _arch_print_header "DWM Desktop Setup Complete"
    echo "Installed: Xorg, DWM (CTT fork), Picom, Dunst, Dmenu, Alacritty, PipeWire, Thunar"
    echo "DWM source: $dwm_dir"
    echo ""
    echo "Manual steps:"
    echo "  - Edit DWM config:  $dwm_dir/config.h  (then sudo make clean install)"
    echo "  - Set wallpaper:    Edit ~/.xinitrc feh line"
    echo "  - Reboot or log out to TTY1 and X/DWM will launch automatically"
}

# ---------------------------------------------------------------------------
# Phase: Gaming
# ---------------------------------------------------------------------------

arch-setup-gaming() {
    _arch_print_header "Phase: Gaming (Steam + AMD stack)"

    if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
        _arch_print_step "Enabling multilib repository in /etc/pacman.conf"
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    else
        _arch_print_step "multilib already enabled — skipping"
    fi

    _arch_print_step "Installing AMD GPU drivers"
    _arch_install_packages \
        mesa lib32-mesa \
        vulkan-radeon lib32-vulkan-radeon \
        libva-mesa-driver lib32-libva-mesa-driver \
        mesa-vdpau lib32-mesa-vdpau \
        vulkan-icd-loader lib32-vulkan-icd-loader

    _arch_print_step "Installing gaming packages"
    _arch_install_packages \
        steam gamemode lib32-gamemode \
        mangohud lib32-mangohud \
        wine wine-gecko wine-mono winetricks \
        lutris gamescope

    _arch_print_step "Installing AUR gaming packages"
    _arch_install_aur_packages protonup-qt corectrl

    local gamemode_ini="$HOME/.config/gamemode.ini"
    if [[ ! -f "$gamemode_ini" ]]; then
        _arch_print_step "Creating gamemode config with AMD optimizations"
        mkdir -p "$(dirname "$gamemode_ini")"
        cat > "$gamemode_ini" << 'GAMEMODE'
[general]
renice = 10
ioprio = 0
inhibit_screensaver = 1

[gpu]
apply_gpu_optimisations = accept-responsibility
amd_performance_level = high

[custom]
start = notify-send "GameMode" "Optimizations activated"
end = notify-send "GameMode" "Optimizations deactivated"
GAMEMODE
    else
        _arch_print_step "gamemode.ini already exists — skipping"
    fi

    _arch_print_header "Gaming Setup Complete"
    echo "Installed: AMD Vulkan/VA-API/VDPAU drivers (32- and 64-bit)"
    echo "Installed: Steam, Lutris, Gamescope, MangoHud, GameMode, Wine"
    echo "Installed: protonup-qt, corectrl (AUR)"
    echo ""
    echo "Manual steps:"
    echo "  - Run protonup-qt to download latest Proton-GE"
    echo "  - Suggested Steam launch options:"
    echo "      gamemoderun mangohud %command%"
    echo "  - For gamescope:"
    echo "      gamescope -W 2560 -H 1440 -f -- gamemoderun mangohud %command%"
    echo "  - Launch corectrl for GPU fan/clock management"
}

# ---------------------------------------------------------------------------
# Phase: VM (QEMU/KVM single-GPU passthrough prep)
# ---------------------------------------------------------------------------

arch-setup-vm() {
    _arch_print_header "Phase: QEMU/KVM Single-GPU Passthrough Prep"

    _arch_print_step "Installing QEMU/KVM and virt-manager"
    _arch_install_packages \
        qemu-full libvirt virt-manager dnsmasq ebtables ovmf swtpm

    _arch_print_step "Adding $USER to libvirt and kvm groups"
    sudo usermod -aG libvirt "$USER"
    sudo usermod -aG kvm "$USER"

    _arch_print_step "Enabling libvirtd service"
    sudo systemctl enable --now libvirtd

    local hooks_dir="/etc/libvirt/hooks"
    local qemu_hook="$hooks_dir/qemu"
    if [[ ! -f "$qemu_hook" ]]; then
        _arch_print_step "Creating QEMU hook dispatcher at $qemu_hook"
        sudo mkdir -p "$hooks_dir"
        sudo tee "$qemu_hook" > /dev/null << 'QEMUHOOK'
#!/bin/bash
GUEST="$1"
PHASE="$2"
ACTION="$3"

HOOK_DIR="/etc/libvirt/hooks/qemu.d/$GUEST/$PHASE/$ACTION"
if [[ -d "$HOOK_DIR" ]]; then
    for script in "$HOOK_DIR"/*.sh; do
        [[ -f "$script" ]] && bash "$script"
    done
fi
QEMUHOOK
        sudo chmod +x "$qemu_hook"
    else
        _arch_print_step "QEMU hook dispatcher already exists — skipping"
    fi

    local start_dir="$hooks_dir/qemu.d/win10/prepare/begin"
    local start_script="$start_dir/start.sh"
    if [[ ! -f "$start_script" ]]; then
        _arch_print_step "Creating GPU passthrough start script template"
        sudo mkdir -p "$start_dir"
        sudo tee "$start_script" > /dev/null << 'STARTSH'
#!/bin/bash
# UPDATE the PCI IDs below to match your GPU (see lspci -nn)
GPU_VIDEO="0000:XX:XX.0"
GPU_AUDIO="0000:XX:XX.1"

systemctl stop display-manager.service
sleep 2

echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null

modprobe -r amdgpu

virsh nodedev-detach "pci_${GPU_VIDEO//[:.]/_}"
virsh nodedev-detach "pci_${GPU_AUDIO//[:.]/_}"

modprobe vfio-pci
STARTSH
        sudo chmod +x "$start_script"
    else
        _arch_print_step "GPU passthrough start script already exists — skipping"
    fi

    local stop_dir="$hooks_dir/qemu.d/win10/release/end"
    local stop_script="$stop_dir/stop.sh"
    if [[ ! -f "$stop_script" ]]; then
        _arch_print_step "Creating GPU passthrough stop script template"
        sudo mkdir -p "$stop_dir"
        sudo tee "$stop_script" > /dev/null << 'STOPSH'
#!/bin/bash
# UPDATE the PCI IDs below to match your GPU (see lspci -nn)
GPU_VIDEO="0000:XX:XX.0"
GPU_AUDIO="0000:XX:XX.1"

modprobe -r vfio-pci

virsh nodedev-reattach "pci_${GPU_VIDEO//[:.]/_}"
virsh nodedev-reattach "pci_${GPU_AUDIO//[:.]/_}"

modprobe amdgpu

echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

systemctl start display-manager.service
STOPSH
        sudo chmod +x "$stop_script"
    else
        _arch_print_step "GPU passthrough stop script already exists — skipping"
    fi

    _arch_print_header "VM Passthrough Setup Complete"
    echo "Installed: QEMU, libvirt, virt-manager, OVMF, swtpm"
    echo "Groups:    $USER added to libvirt, kvm"
    echo "Hooks:     $hooks_dir/qemu (dispatcher)"
    echo "Templates: $start_dir/start.sh"
    echo "           $stop_dir/stop.sh"
    echo ""

    echo "Detected AMD GPU PCI IDs:"
    lspci -nn | grep -i 'amd.*\(vga\|audio\|display\)' || echo "  (none detected — verify with: lspci -nn | grep -i amd)"
    echo ""

    echo "REQUIRED manual steps:"
    echo "  1. Update PCI IDs in the start/stop scripts above to match your GPU"
    echo "  2. Add kernel parameters to your bootloader:"
    echo "       amd_iommu=on iommu=pt video=efifb:off"
    echo "     For GRUB: edit GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub"
    echo "     then run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "  3. Download your GPU BIOS/ROM (use GPU-Z on Windows or techpowerup.com)"
    echo "  4. Disable Resizable BAR in BIOS (can cause passthrough issues)"
    echo "  5. Log out and back in (or reboot) for group changes to take effect"
}

# ---------------------------------------------------------------------------
# Phase: All (guided full setup)
# ---------------------------------------------------------------------------

arch-setup-all() {
    _arch_print_header "Arch Linux Full Setup — Guided"

    echo "This will run the following phases:"
    echo "  1. Base system (paru, snapper, base-devel)"
    echo "  2. Shell environment (zsh, starship, CTT mybash)"
    echo "  3. Desktop environment (choose Hyprland or DWM)"
    echo "  4. Gaming (Steam, AMD drivers, Lutris)"
    echo ""
    echo "Note: VM passthrough is excluded (hardware-specific). Run arch-setup-vm separately."
    echo ""

    read -rp "Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        return 0
    fi

    arch-setup-base || { echo "Base setup failed. Aborting."; return 1; }

    arch-setup-shell || { echo "Shell setup failed. Aborting."; return 1; }

    echo ""
    echo "Choose desktop environment:"
    echo "  1) Hyprland (Wayland — recommended for gaming)"
    echo "  2) DWM (X11 — Chris Titus Tech fork)"
    echo "  3) Skip desktop setup"
    echo ""
    read -rp "Selection [1/2/3]: " desktop_choice

    case "$desktop_choice" in
        1)
            arch-setup-desktop-hyprland || { echo "Hyprland setup failed."; return 1; }
            ;;
        2)
            arch-setup-desktop-dwm || { echo "DWM setup failed."; return 1; }
            ;;
        3)
            echo "Skipping desktop setup."
            ;;
        *)
            echo "Invalid selection — skipping desktop setup."
            ;;
    esac

    arch-setup-gaming || { echo "Gaming setup failed."; return 1; }

    _arch_print_header "Full Setup Complete"
    echo "All phases finished. Reboot recommended."
    echo ""
    echo "Optional next steps:"
    echo "  - Run arch-setup-vm for GPU passthrough"
    echo "  - Run protonup-qt to download Proton-GE"
    echo "  - Change default shell: chsh -s \$(which zsh)"
}
