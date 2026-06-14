---
layout: home
title: Qaskade
---

# Qaskade

A keyboard-driven [Hyprland](https://hyprland.org) desktop shell powered by [Quickshell](https://quickshell.outfoxxed.me/).

![Demo](https://github.com/quirijndubois/Qaskade/raw/main/demo.gif)

## Quick Start

```bash
git clone https://github.com/quirijndubois/Qaskade.git
cd Qaskade
./install.sh
```

See [Installation](installation.html) for detailed setup.

## What's in here

**Getting Started** — install, dependencies, and keybinds.

**Components** — each major feature documented with a user guide and internal implementation details:

- [Bar](bar.html) — the status bar, hover popup system, and bar designs
- [Bar Modules](bar-modules.html) — CPU, memory, GPU, audio, music, battery, clock, Bluetooth, network, workspaces, tray
- [Notifications](notifications.html) — the notification daemon, in-bar display, and popup history
- [Lock Screen](lock-screen.html) — Wayland session lock with 5 designs and animations
- [Settings Overlay](settings-overlay.html) — fuzzy search, all settings pages, filesystem browser, math evaluator

**Theming** — how colors work end to end:

- [Theme Engine](theme-engine.html) — animated palette switching and system-wide sync
- [Palette Extraction](palette-extraction.html) — extracting colors from wallpapers with WCAG enforcement
- [Palettes](themes.html) — all 18 built-in color themes

**Internals** — deeper into the architecture:

- [IPC & Shell Root](ipc.html) — how keybinds and scripts talk to the running shell
- [Configuration](configuration.html) — config file structure and watch mode
