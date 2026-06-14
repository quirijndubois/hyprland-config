---
layout: home
title: Bar Modules
---

# Bar Modules

Each module lives in its own QML file and can be independently toggled via **Settings → Appearance**.

---

## CPU (`CpuModule.qml`)

**User:** Shows aggregate CPU usage as `cpu 42%`. Hover to see a per-core bar chart and top 5 processes by CPU usage.

**Internals:** Reads `/proc/stat` every 2 seconds using a `Process` running `grep '^cpu' /proc/stat`. The first line gives aggregate stats; remaining lines are per-core. Usage is computed as:

```
usage = (dTotal - dIdle) / dTotal * 100
```

where `dTotal` and `dIdle` are deltas from the previous poll. Top processes are fetched via `ps --sort=-pcpu` only when the popup is open, refreshed every 3 seconds.

---

## Memory (`MemoryModule.qml`)

**User:** Shows used memory as `mem 8.1G`. Hover to see a usage bar and top 5 processes by RSS.

**Internals:** Reads `/proc/meminfo` every 5 seconds. Parses `MemTotal`, `MemFree`, `Buffers`, `Cached`, `SReclaimable`. Used = Total - Free - Buffers - Cached - SReclaimable. Top processes fetched via `ps --sort=-rss` when popup is open.

---

## GPU (`GpuModule.qml`)

**User:** Shows NVIDIA GPU utilization as `gpu 34%`. Hover for GPU % + VRAM usage bar.

**Internals:** Runs `nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits` every 3 seconds. Parses the CSV output. Only shows when the query succeeds (NVIDIA driver present).

---

## Battery (`BatteryModule.qml`)

**User:** Shows battery percentage and charging state (e.g. `bat 87%` or `bat 87% ↑`). Hover to see estimated time remaining and charging status.

**Internals:** Reads `/sys/class/power_supply/BAT0/` (capacity, status) every 30 seconds. Time remaining calculated from energy now vs. energy full and current power draw from `power_now`.

---

## Clock (`ClockModule.qml`)

**User:** Shows current time as `HH:MM`. Hover to see a date and seconds.

**Internals:** Uses a QML `Timer` repeating every second, updating with `Qt.formatTime(new Date(), ...)`.

---

## Audio (`AudioModule.qml`)

**User:** Shows master volume as `vol 72%` or `vol mute`. Hover to see a master volume slider with a draggable knob and per-app volume sliders with live peak meters. Right-click opens `pavucontrol`.

**Internals:** Uses Quickshell's PipeWire integration. `Pipewire.defaultAudioSink` is tracked with `PwObjectTracker`. Per-app streams are collected by watching `Pipewire.nodes` for `PwNodeType.AudioOutStream`. Updates are debounced with `Qt.callLater` to avoid re-renders on every node change.

Peak meters use `PwNodePeakMonitor` per stream — enabled only when the popup is open (`BarHover.activeModule === "audio"`). The peak bar color flips from teal to red above 85%.

Volume slider allows dragging up to 150% (1.5) — the fill color turns red above 100%.

---

## Music / MPRIS (`MusicModule.qml`)

**User:** Shows 5 animated dancing bars while music plays, paused bars when paused, hidden when stopped. Hover for track title, artist, seek bar, and transport controls (previous / play-pause / next).

**Internals:** Uses `Quickshell.Services.Mpris`. Player selection prefers a currently-playing player; falls back to any available player. Animation runs a `Timer` at 50ms intervals updating 5 amplitude values using sine waves with different phases and frequencies:

```js
amps[i] = base + range * Math.abs(Math.sin(phase * freq + offset))
```

Seek position is tracked locally with a 500ms `Timer` that increments `displayPos` while playing, avoiding constant IPC calls. Clicking the progress bar seeks via `player.position = newPos`.

---

## Bluetooth (`BluetoothModule.qml`)

**User:** Shows Bluetooth state (`bt on` / `bt off`). Hover to see connected devices. Full management (pair, connect, disconnect) in **Settings → Bluetooth**.

**Internals:** Calls `bluetoothctl show` to get power state, and `bluetoothctl info` + `bluetoothctl devices Connected` for the popup. Runs on hover.

---

## Network (`NetworkModule.qml`)

**User:** Shows network interface and connection (e.g. `eth0` or WiFi SSID). Hover for IP address.

**Internals:** Runs `ip route get 1.1.1.1` to find the active interface, then `ip addr show <iface>` for IP, and `iwgetid -r` for SSID if wireless.

---

## Sleep Inhibit (`InhibitModule.qml` + `InhibitState.qml`)

**User:** Click to toggle sleep inhibition (prevents idle lock/sleep). The module changes color when active.

**Internals:** `InhibitState.qml` is a `pragma Singleton` holding a single `inhibited: bool`. `InhibitModule` toggles it on click and runs/kills a `systemd-inhibit` process to hold the inhibitor lock.

---

## System Tray (`TrayModule.qml`)

**User:** Shows icons for any `StatusNotifierItem` application (Solaar, network manager, etc.).

**Internals:** Uses Quickshell's built-in `SystemTray` model. Each tray item renders its icon and opens its context menu on right-click.

---

## Workspaces (`WorkspacesModule.qml`)

**User:** Shows workspace numbers for the current monitor. Click to switch. The active workspace has a highlighted background that slides between workspaces.

**Internals:** Uses `Quickshell.Hyprland.workspaces` as the model. The animated highlight is a `Rectangle` whose `x` tracks `highlightX` with a 200ms `OutCubic` `NumberAnimation`. `highlightX` is updated via `onIsFocusedChanged` using `Qt.callLater` to ensure the delegate's position is settled before reading it.

The workspaces module also doubles as the notification center — its hover popup shows recent notifications (see [Notifications](notifications.html)).

---

[← Bar](bar.html) • [Lock Screen →](lock-screen.html)
