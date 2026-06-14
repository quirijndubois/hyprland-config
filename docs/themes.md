---
layout: home
title: Themes
---

# Themes

Qaskade includes 18 carefully curated color palettes with smooth 500ms animated transitions.

## Live Color Syncing

Theme changes automatically sync to:
- Quickshell (instant)
- Kitty terminal (instant)
- Firefox (via pywalfox, if installed)
- System dark/light mode (GTK3/4 apps, Qt6 apps via qt6ct)

## Dark Themes

### Catppuccin Collection

**Mocha** (default)
- Rich, warm dark theme
- Great contrast and readability
- Primary accent: Cyan

**Macchiato**
- Slightly lighter than Mocha
- Softer color palette
- Primary accent: Blue

**Frappe**
- Coolest of the Catppuccin variants
- Sophisticated appearance
- Primary accent: Blue

### Modern Themes

**Tokyo Night**
- Japanese-inspired color scheme
- Night-time aesthetic
- Primary accent: Blue

**Dracula**
- High contrast, vibrant colors
- Famous and widely recognized
- Primary accent: Cyan

### Neutral Themes

**Gruvbox**
- Retro groove colors
- Warm and comfortable
- Primary accent: Teal

**Nord**
- Arctic, north-bluish palette
- Calm and professional
- Primary accent: Cyan

**One Dark**
- Atom-inspired dark theme
- Well-balanced colors
- Primary accent: Blue

**Everforest**
- Forest-inspired, natural colors
- Soft and easy on eyes
- Primary accent: Green

**Solarized Dark**
- Precision colors for machines and people
- Excellent for code
- Primary accent: Cyan

### Rose Pine

**Rose Pine**
- Soho vibes, warm tones
- Sophisticated color balance
- Primary accent: Cyan

## Light Themes

### Catppuccin Latte
- Warm, light aesthetic
- High readability
- Primary accent: Blue

### Modern Light

**Solarized Light**
- Precision colors, light variant
- Excellent contrast
- Primary accent: Blue

**Gruvbox Light**
- Retro groove, light variant
- Warm and inviting
- Primary accent: Teal

**Nord Light**
- Arctic, light variant
- Professional appearance
- Primary accent: Blue

### Contemporary Light

**Rose Pine Dawn**
- Rose Pine light variant
- Warm and elegant
- Primary accent: Blue

**One Light**
- Atom-inspired light theme
- Clean and minimal
- Primary accent: Blue

## Wallpaper Palette Extraction

Extract colors from any image to create a custom palette:

1. Open **Settings → Appearance → Wallpaper**
2. Navigate to any wallpaper
3. Press `A` to extract palette

The system will:
- Extract dominant colors from the image
- Enforce WCAG contrast requirements (text ≥ 7:1, accents ≥ 4.5:1)
- Apply the palette system-wide
- Randomize slightly so each extraction differs

## Random Wallpaper

Get a random wallpaper with automatically extracted palette:

```
Alt + R
```

This will:
1. Pick a random image from `~/wallpapers/`
2. Apply it with a random animated transition (fade, slide, wipe, wave, grow, center, outer, any)
3. Extract and apply its color palette instantly
4. Update all connected applications

## Theme Switching

Themes are fully animated over 500ms. You can rapidly switch themes without visual jarring.

### Via Settings
**Settings → Appearance → Palette** - Select any of the 18 themes

### Via Wallpaper Extraction
Press `A` on any wallpaper to extract and apply a custom palette instantly

### Via Random Wallpaper
`Alt + R` picks a random wallpaper and applies its extracted palette

## Custom Palettes

Custom palettes extracted from wallpapers are stored in:
```
~/.config/quickshell/custom-palette
```

This file is automatically managed by the wallpaper extraction process.

## Color Accessibility

All palettes are verified for:
- **Text contrast** ≥ 7:1 ratio (WCAG AAA standard)
- **Accent contrast** ≥ 4.5:1 ratio (WCAG AA standard)

Extracted palettes are automatically adjusted to meet these standards.

---

[← Customization](customization.html) • [Configuration →](configuration.html)
