#!/bin/sh
# install.sh — FreeBSD Hyprland setup script
# Intel GPU + Wayland + Development
# Adapted from Dieggho/FreeBSD_Backups
#
# Run as your regular user (not root). doas will prompt for password when needed.
# Usage: sh install.sh

set -e

####################
# CONFIG — edit these
####################
USERNAME=$(whoami)
UID_NUM=$(id -u)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Setting up FreeBSD Hyprland (Intel GPU, dev) for user: $USERNAME (uid=$UID_NUM)"
echo ""

####################
# 1. Install packages
####################
echo "[1/7] Installing packages from My_Pkgs..."
# Filter out comment lines then install
grep -v '^#' "$DOTFILES_DIR/My_Pkgs" | grep -v '^$' | xargs doas pkg install -y
echo "Done."

####################
# 2. System config files
####################
echo "[2/7] Installing system config files..."

doas cp "$DOTFILES_DIR/etc/rc.conf"      /etc/rc.conf
doas cp "$DOTFILES_DIR/etc/sysctl.conf"  /etc/sysctl.conf
doas cp "$DOTFILES_DIR/boot/loader.conf" /boot/loader.conf
doas cp "$DOTFILES_DIR/usr/local/etc/doas.conf" /usr/local/etc/doas.conf
doas chmod 0400 /usr/local/etc/doas.conf

echo "Done. Review /etc/rc.conf for your network interface name!"

####################
# 3. XDG runtime dir (FreeBSD-specific Hyprland requirement)
####################
echo "[3/7] Setting up XDG runtime directory..."
doas mkdir -p "/var/run/user/$UID_NUM"
doas chown "$USERNAME" "/var/run/user/$UID_NUM"
doas chmod 700 "/var/run/user/$UID_NUM"
echo "Done. (uid=$UID_NUM)"

####################
# 4. Add user to required groups
####################
echo "[4/7] Adding $USERNAME to video and wheel groups..."
doas pw groupmod video -m "$USERNAME"
doas pw groupmod wheel -m "$USERNAME"
# seatd group (needed for seat management under Wayland)
doas pw groupmod _seatd -m "$USERNAME" 2>/dev/null || true
echo "Done."

####################
# 5. Copy dotfiles
####################
echo "[5/7] Copying dotfiles to home directory..."

mkdir -p \
  ~/.config/hypr \
  ~/.config/waybar \
  ~/.config/foot \
  ~/.config/mako \
  ~/Pictures/Screenshots

cp "$DOTFILES_DIR/home/user/.config/hypr/hyprland.conf"       ~/.config/hypr/hyprland.conf
cp "$DOTFILES_DIR/home/user/.config/waybar/config.jsonc"      ~/.config/waybar/config.jsonc
cp "$DOTFILES_DIR/home/user/.config/waybar/style.css"         ~/.config/waybar/style.css
cp "$DOTFILES_DIR/home/user/.config/foot/foot.ini"            ~/.config/foot/foot.ini
cp "$DOTFILES_DIR/home/user/.config/mako/config"              ~/.config/mako/config

echo "Done."

####################
# 6. Shell environment
####################
echo "[6/7] Writing shell environment (~/.profile)..."
cat >> ~/.profile << 'EOF'

# --- Wayland / Hyprland environment ---
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export LIBVA_DRIVER_NAME=iHD        # Intel VA-API
export WLR_NO_HARDWARE_CURSORS=1
export XDG_RUNTIME_DIR=/var/run/user/$(id -u)

# --- Dev tools ---
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# Auto-start Hyprland on TTY1 login
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/ttyv0" ]; then
  exec Hyprland
fi
EOF
echo "Done."

####################
# 7. Enable services
####################
echo "[7/7] Enabling system services..."
doas service dbus enable  2>/dev/null || true
doas service seatd enable 2>/dev/null || true
echo "Done."

####################
# Done
####################
echo ""
echo "============================================"
echo " Setup complete!"
echo "============================================"
echo ""
echo "IMPORTANT next steps before rebooting:"
echo ""
echo "  1. Edit /etc/rc.conf — confirm your network interface name:"
echo "     Run: ifconfig   (look for em0, igb0, re0, bge0, etc.)"
echo ""
echo "  2. Update UID in hyprland.conf if your UID is not 1001:"
echo "     Your UID: $UID_NUM"
echo "     File: ~/.config/hypr/hyprland.conf  (search XDG_RUNTIME_DIR)"
echo ""
echo "  3. Set a wallpaper path in hyprland.conf:"
echo "     Look for: swww img ~/Pictures/wallpaper.jpg"
echo ""
echo "  4. Reboot, then log in on TTY1 — Hyprland will auto-start."
echo ""
echo "  Keybinds: SUPER+Enter=terminal, SUPER+D=launcher, SUPER+Q=close"
echo ""
