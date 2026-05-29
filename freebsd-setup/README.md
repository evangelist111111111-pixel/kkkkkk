# FreeBSD Hyprland Setup
**Intel GPU · Wayland · Development**
Adapted from [Dieggho/FreeBSD_Backups](https://github.com/Dieggho/FreeBSD_Backups)

---

## What's included

| File | Purpose |
|---|---|
| `install.sh` | One-shot setup script |
| `My_Pkgs` | Package list (install manually or via script) |
| `etc/rc.conf` | System services, networking, GPU |
| `etc/sysctl.conf` | Kernel tuning for desktop use |
| `boot/loader.conf` | Intel DRM + audio boot modules |
| `usr/local/etc/doas.conf` | Privilege escalation config |
| `home/user/.config/hypr/hyprland.conf` | Hyprland compositor config |
| `home/user/.config/waybar/` | Status bar config + Nord theme CSS |
| `home/user/.config/foot/foot.ini` | Terminal config (Nord colors) |
| `home/user/.config/mako/config` | Notification daemon config |

---

## Quick start

```sh
# 1. Clone this repo on your fresh FreeBSD system
pkg install git
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ~/dotfiles
cd ~/dotfiles

# 2. Run the installer
sh install.sh

# 3. Read the post-install notes it prints, then reboot
```

---

## Before running install.sh — check your network interface

```sh
ifconfig
```
Edit `etc/rc.conf` and replace `em0` with your actual interface name (`igb0`, `re0`, `bge0`, `wlan0`, etc.).

---

## After install — key bindings

| Key | Action |
|---|---|
| `SUPER + Enter` | Open terminal (foot) |
| `SUPER + D` | App launcher (fuzzel) |
| `SUPER + B` | Browser (firefox) |
| `SUPER + Q` | Close window |
| `SUPER + SHIFT + Q` | Exit Hyprland |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle float |
| `SUPER + H/L/K/J` | Focus left/right/up/down |
| `SUPER + 1-5` | Switch workspace |
| `SUPER + SHIFT + 1-5` | Move window to workspace |
| `Print` | Screenshot (saved to ~/Pictures/Screenshots) |
| `SHIFT + Print` | Screenshot region |

---

## Intel GPU notes

- `i915kms` is loaded at boot via `loader.conf`
- Hardware video decode uses `iHD` (VA-API) via `libva-intel-media-driver`
- `WLR_NO_HARDWARE_CURSORS=1` is set to avoid cursor glitches common on Intel

---

## Dev workflow

Default editor is `nvim`. `tmux`, `lazygit`, `fzf`, `ripgrep`, `fd-find`, `bat`, and `eza` are included in `My_Pkgs`. Uncomment language runtimes (Node, Go, Rust, Java) in `My_Pkgs` as needed.

---

## Theming

Everything uses **Nord** color scheme. To change themes, edit:
- `~/.config/waybar/style.css`
- `~/.config/foot/foot.ini` (color section)
- `~/.config/mako/config`
- `~/.config/hypr/hyprland.conf` (border colors)
