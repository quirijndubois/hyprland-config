---
layout: home
title: Troubleshooting
---

# Troubleshooting

## Common Issues

### Quickshell Won't Start

**Problem:** Quickshell doesn't start or crashes immediately.

**Solution:**
1. Check if dunst is running (it conflicts with Quickshell's notification service):
   ```bash
   systemctl --user mask dunst
   systemctl --user restart dunst
   ```

2. Restart Quickshell manually:
   ```bash
   pkill quickshell
   quickshell &
   ```

3. Check logs:
   ```bash
   journalctl --user -u quickshell -n 50
   ```

### Settings Overlay Not Opening

**Problem:** `Alt + S` doesn't open the settings overlay.

**Solution:**
1. Verify keybindings are loaded correctly:
   ```bash
   hyprctl getkeymap
   ```

2. Restart Quickshell:
   ```bash
   pkill -f quickshell
   sleep 1
   quickshell &
   ```

3. Check if another application is intercepting the keybind

### Wallpaper Not Changing

**Problem:** Wallpaper doesn't update when selected.

**Solution:**
1. Ensure `awww-daemon` is running:
   ```bash
   pgrep awww-daemon || awww-daemon &
   ```

2. Check that wallpaper files exist in `~/wallpapers/`

3. Try manually applying a wallpaper:
   ```bash
   awww img /path/to/wallpaper.jpg
   ```

### Colors Not Syncing to Firefox

**Problem:** Theme changes don't update Firefox colors.

**Solution:**
1. Verify pywalfox is installed and running:
   ```bash
   $HOME/.conda/envs/pywalfox/bin/pywalfox status
   ```

2. Restart Firefox or manually run:
   ```bash
   $HOME/.conda/envs/pywalfox/bin/pywalfox update
   ```

3. Install the Firefox extension if not already installed:
   - Firefox Add-ons → Search "pywalfox"
   - Install and grant permissions

### Lock Screen Not Working

**Problem:** `Alt + Delete` doesn't lock the screen.

**Solution:**
1. Check if `unix_chkpwd` is available:
   ```bash
   which unix_chkpwd
   ```

2. Verify Wayland session:
   ```bash
   echo $WAYLAND_DISPLAY
   ```

3. Try manually locking:
   ```bash
   qs ipc call lock lock
   ```

### Bluetooth Module Not Showing Devices

**Problem:** Bluetooth devices don't appear in settings.

**Solution:**
1. Ensure Bluetooth is enabled:
   ```bash
   sudo systemctl start bluetooth
   ```

2. Check if device is discoverable and in range

3. Pair device via settings overlay or bluetoothctl:
   ```bash
   bluetoothctl scan on
   ```

### Notifications Not Appearing

**Problem:** System notifications don't show up in the notification center.

**Solution:**
1. Verify dunst is masked:
   ```bash
   systemctl --user status dunst
   # Should show "masked"
   ```

2. Restart the Notification D-Bus service:
   ```bash
   pkill quickshell
   sleep 1
   quickshell &
   ```

### CPU/GPU Module Not Showing Data

**Problem:** CPU or GPU monitor shows no data or "N/A".

**Solution:**
1. For CPU - this is built-in, should always work
2. For GPU (NVIDIA):
   ```bash
   nvidia-smi
   ```
   If this fails, NVIDIA drivers aren't properly installed

3. Toggle the module off and on via Settings → Appearance

### Configuration Not Syncing

**Problem:** Config changes don't take effect.

**Solution:**
1. Run the install script:
   ```bash
   cd ~/qaskade
   ./install.sh
   ```

2. Or use watch mode to auto-sync on changes:
   ```bash
   ./install.sh --watch
   ```

3. Restart Quickshell:
   ```bash
   pkill quickshell
   quickshell &
   ```

## Performance Issues

### High CPU Usage

**Solution:**
1. Disable animations if they're causing issues:
   - Edit `~/.config/hypr/hyprland.lua`
   - Set `hl.config({ animations = { enabled = false } })`

2. Reduce blur passes in hyprland.lua:
   ```lua
   blur = {
       enabled = true,
       size = 5,
       passes = 1,  -- Reduce from 3 to 1
   }
   ```

3. Disable unused bar modules:
   - Settings → Appearance → Toggle off unused modules

### Laggy Animations

**Solution:**
1. Reduce animation speeds in `hyprland.lua`
2. Lower monitor refresh rate in hyprland.lua
3. Disable blur or reduce passes

## Getting Help

If you encounter an issue not listed here:

1. **Check the GitHub issues**: https://github.com/quirijndubois/qaskade/issues

2. **Provide debug info:**
   ```bash
   echo $WAYLAND_DISPLAY
   hyprctl version
   quickshell --version
   ```

3. **Include relevant logs:**
   ```bash
   journalctl --user -n 100 > log.txt
   ```

---

[← Requirements](requirements.html) • [Home →](index.html) • [Keybinds](keybinds.html)
