# SnowFoxOS v2 — Installationsanleitung

## Schritt 1: Debian 12 installieren

1. [Debian 12 Netinst ISO](https://www.debian.org/releases/stable/debian-installer/) herunterladen
2. Auf USB flashen (z.B. mit `dd` oder Balena Etcher)
3. Von USB booten
4. Installation: **"Standard system utilities"** — KEIN Desktop auswählen!
5. Nach der Installation einloggen

## Schritt 2: SnowFoxOS installieren

```bash
# Git installieren
sudo apt install git -y

# Repo klonen
git clone https://github.com/DEIN-USERNAME/SnowFoxOS.git
cd SnowFoxOS

# Installer ausführen
sudo ./install.sh
```

## Schritt 3: Neu starten

```bash
sudo reboot
```

Sway startet jetzt automatisch beim Login.

## Häufige Probleme

**Sway startet nicht:**
```bash
# GPU-Treiber prüfen
sway 2>&1 | head -20
```

**Kein Audio:**
```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

**WiFi funktioniert nicht:**
```bash
# Firmware nachinstallieren (für viele Laptops nötig)
sudo apt install firmware-iwlwifi firmware-realtek firmware-atheros
```

**VSCodium lädt nicht:**
```bash
# Wayland-Flag setzen
echo "--enable-features=WaylandWindowDecorations --ozone-platform=wayland" >> ~/.config/codium-flags.conf
```
