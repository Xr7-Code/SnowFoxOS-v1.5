<h1 align="center">Discontinued</h1>

<p align="center">Active Project: SnowFoxOS-v2-i3</p>

# 🦊 SnowFoxOS v2

> **Minimal. Schnell. Schön.**

Ein schlankes Linux-Betriebssystem basierend auf **Debian 12 "Bookworm"** mit **Sway Wayland Compositor** und einem konsistenten Lila/Orange Design.

---

## ✨ Was ist SnowFoxOS?

SnowFoxOS ist keine eigene Distro — es ist ein **sorgfältig ausgewählter Stack von Konfigurationen und Scripts**, der aus einer frischen Debian 12 Installation in wenigen Minuten ein schönes, minimales System macht.

**Kein Bloat. Kein Unsinn. Nur was man braucht.**

---

## 📋 Voraussetzungen

- **Basis:** Debian 12 "Bookworm" Minimal (ohne Desktop)
- **RAM:** 2GB minimum, 4GB empfohlen
- **Speicher:** 15GB minimum
- **CPU:** x86_64 (Intel/AMD, 2015 oder neuer)
- **GPU:** Jede GPU mit Wayland/DRM Support

---

## 🚀 Installation

```bash
# 1. Repository klonen
git clone https://github.com/DEIN-USERNAME/SnowFoxOS.git
cd SnowFoxOS

# 2. Installer ausführen
chmod +x install.sh
sudo ./install.sh

# 3. Nach der Installation neu starten
sudo reboot
```

Nach dem Neustart startet Sway automatisch über greetd.

---

## 🎯 Vorinstallierte Apps

| App | Beschreibung |
|-----|-------------|
| Firefox ESR | Web Browser |
| Foot | Terminal (ultraleicht) |
| Thunar | Dateimanager |
| Neovim | Terminal-Editor |
| VSCodium | GUI Code-Editor (open-source VSCode) |
| Galculator | Taschenrechner |
| Imv | Bildanzeige |
| Btop | Systemmonitor |
| MPV | Videoplayer |
| Evince | PDF-Anzeige |

---

## 📦 Apps installieren

**Via APT (Debian-Pakete):**
```bash
sudo apt install libreoffice gimp vlc
sudo apt remove libreoffice
```

**Via Flatpak (Steam, Discord etc.):**
```bash
flatpak install flathub com.valvesoftware.Steam
flatpak install flathub com.discordapp.Discord
flatpak uninstall com.valvesoftware.Steam
```

**Via SnowFox Store (interaktiv):**
```
Mod + S
```

---

## ⌨️ Shortcuts

| Shortcut | Aktion |
|----------|--------|
| `Mod + Enter` | Terminal |
| `Mod + B` | Firefox |
| `Mod + E` | Dateimanager |
| `Mod + C` | VSCodium |
| `Mod + R` | App-Launcher |
| `Mod + S` | SnowFox Store |
| `Mod + N` | WiFi-Manager |
| `Mod + X` | Sperren |
| `Mod + P` | Power Menu |
| `Mod + F1` | Alle Shortcuts |
| `Print` | Screenshot |
| `Mod + Shift+S` | Bereich → Clipboard |
| `Mod + Q` | Fenster schließen |
| `Mod + F` | Vollbild |
| `Mod + 1–9` | Workspace |
| `Mod + Shift+E` | Beenden/Logout |

---

## 🎨 Design

- **Primärfarbe:** `#9B59B6` (Lila)  
- **Akzentfarbe:** `#E67E22` (Orange)  
- **Hintergrund:** `#0A0A0A` (fast Schwarz)  
- **Icons:** Papirus-Dark  
- **Font:** Noto Sans  

---

## 🛠️ Configs anpassen

Alle Konfigurationen liegen in `~/.config/`:

```
~/.config/sway/config       ← Window Manager
~/.config/waybar/           ← Status-Bar
~/.config/wofi/             ← App-Launcher
~/.config/foot/foot.ini     ← Terminal
~/.config/mako/config       ← Notifications
~/.config/nvim/init.lua     ← Neovim
~/.config/gtk-3.0/          ← GTK Apps
```

---

## 📜 Lizenz

Privat nutzen ✅ | Lernen & Anpassen ✅ | Weiterveröffentlichen ❌

---

*Erstellt mit ❤️ — Basierend auf Debian 12, Sway, Waybar und vielen anderen Open-Source-Projekten.*
