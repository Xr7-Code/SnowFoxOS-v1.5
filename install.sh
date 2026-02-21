#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                  SnowFoxOS v2 — Ultimate Installer               ║
# ║               Minimal. Schnell. Schön. | 2026 Edition            ║
# ╚══════════════════════════════════════════════════════════════════╝

# Log-Datei initialisieren
LOG="/tmp/snowfoxos_install.log"
echo "--- SnowFoxOS Installation Start: $(date) ---" > "$LOG"

# Farben & Styling
P='\033[0;35m' O='\033[0;33m' G='\033[0;32m' R='\033[0;31m'
B='\033[1m' D='\033[2m' N='\033[0m'

# Hilfsfunktionen
log()  { echo -e "${P}[SnowFox]${N} $1" | tee -a "$LOG"; }
ok()   { echo -e "${G}[  OK  ]${N} $1" | tee -a "$LOG"; }
err()  { echo -e "${R}[ ERR  ]${N} $1" | tee -a "$LOG"; exit 1; }
step() { echo -e "\n${P}${B}━━━ $1 ━━━${N}\n" | tee -a "$LOG"; }
info() { echo -e "${D}         $1${N}" | tee -a "$LOG"; }

print_splash() {
    clear
    echo -e "${P}"
    echo '  ██████╗ ███╗   ██╗ ██████╗ ██╗    ██╗███████╗ ██████╗ ██╗  ██╗'
    echo ' ██╔════╝ ████╗  ██║██╔═══██╗██║    ██║██╔════╝██╔═══██╗╚██╗██╔╝'
    echo ' ╚█████╗  ██╔██╗ ██║██║   ██║██║ █╗ ██║█████╗  ██║   ██║ ╚███╔╝ '
    echo '  ╚═══██╗ ██║╚██╗██║██║   ██║██║███╗██║██╔══╝  ██║   ██║ ██╔██╗ '
    echo ' ██████╔╝ ██║ ╚████║╚██████╔╝╚███╔███╔╝██║     ╚██████╔╝██╔╝╚██╗'
    echo ' ╚═════╝  ╚═╝  ╚═══╝ ╚═════╝  ╚══╝╚══╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝'
    echo -e "${O}                  🦊  SnowFoxOS v2 Installer${N}"
    echo -e "${D}                  Minimal. Schnell. Schön.${N}\n"
}

check_requirements() {
    step "System-Check"
    [[ $EUID -ne 0 ]] && err "Bitte mit sudo ausführen: sudo ./install.sh"
    
    [[ ! -f /etc/debian_version ]] && err "Nur für Debian 12 (Bookworm)!"
    ok "Debian $(cat /etc/debian_version) erkannt"

    ping -c1 -W3 8.8.8.8 &>/dev/null || err "Keine Internetverbindung."
    ok "Internetverbindung steht"

    # User-Erkennung verbessern
    TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}"
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    
    [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]] && err "Konnte Ziel-User nicht ermitteln!"
    ok "Ziel-User: ${TARGET_USER} (${TARGET_HOME})"
}

update_system() {
    step "System aktualisieren"
    info "Paketlisten werden geladen..."
    apt-get update -y -qq >> "$LOG" 2>&1 || info "Warnung bei apt-update, fahre fort..."
    
    info "Upgrades werden installiert..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq >> "$LOG" 2>&1
    ok "System-Update abgeschlossen"

    info "Basis-Abhängigkeiten werden installiert..."
    apt-get install -y -qq --no-install-recommends \
        curl wget git ca-certificates gnupg apt-transport-https \
        software-properties-common dialog xdg-utils xdg-user-dirs \
        dbus-x11 polkit >> "$LOG" 2>&1
    ok "Basis-Pakete bereit"
}

install_sway_stack() {
    step "Sway Wayland-Stack"
    apt-get install -y -qq --no-install-recommends \
        sway swaybg swaylock swayidle \
        waybar wofi foot mako-notifier \
        grim slurp wl-clipboard xwayland \
        brightnessctl pipewire pipewire-pulse wireplumber \
        network-manager network-manager-gnome \
        xdg-desktop-portal xdg-desktop-portal-wlr >> "$LOG" 2>&1
    ok "Sway & Wayland Komponenten installiert"
}

install_apps() {
    step "Apps & Design"
    apt-get install -y -qq --no-install-recommends \
        firefox-esr thunar thunar-archive-plugin thunar-volman \
        neovim galculator imv btop file-roller \
        gvfs gvfs-backends udisks2 \
        papirus-icon-theme fonts-noto fonts-noto-color-emoji \
        fontconfig fonts-inter fonts-jetbrains-mono >> "$LOG" 2>&1
    ok "Apps & Fonts installiert"

    # VSCodium
    if ! command -v codium &>/dev/null; then
        log "VSCodium Repository wird hinzugefügt..."
        curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor > /usr/share/keyrings/vscodium-archive-keyring.gpg
        echo "deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main" > /etc/apt/sources.list.d/vscodium.list
        apt-get update -qq >> "$LOG" 2>&1
        apt-get install -y -qq codium >> "$LOG" 2>&1 && ok "VSCodium installiert"
    fi

    # greetd & tuigreet
    apt-get install -y -qq greetd >> "$LOG" 2>&1
    if [[ ! -f /usr/bin/tuigreet ]]; then
        curl -fsSL "https://github.com/apognu/tuigreet/releases/download/0.9.0/tuigreet-0.9.0-amd64" -o /usr/bin/tuigreet
        chmod +x /usr/bin/tuigreet
    fi
    ok "Login-Manager vorbereitet"
}

setup_configs() {
    step "Konfigurationen kopieren"
    SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CFG="${TARGET_HOME}/.config"

    # Verzeichnisstruktur erstellen
    sudo -u "$TARGET_USER" mkdir -p "$CFG"/{sway,waybar,wofi,foot,mako,nvim,gtk-3.0,gtk-4.0}

    # Configs kopieren (nur wenn sie im Ordner existieren)
    [[ -d "$SDIR/configs" ]] && cp -rv "$SDIR"/configs/* "$CFG/" >> "$LOG" 2>&1
    
    # GTK Branding (Papirus Icons setzen)
    cat > "$CFG/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-icon-theme-name = Papirus-Dark
gtk-theme-name = Adwaita-dark
gtk-font-name = Inter 11
EOF
    cp "$CFG/gtk-3.0/settings.ini" "$CFG/gtk-4.0/settings.ini"

    chown -R "$TARGET_USER:$TARGET_USER" "$CFG"
    ok "User-Configs & Branding angewendet"
}

setup_scripts_and_assets() {
    step "Assets & Scripts"
    SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Wallpapers
    WP_DIR="${TARGET_HOME}/Pictures/SnowFoxOS"
    sudo -u "$TARGET_USER" mkdir -p "$WP_DIR"
    cp "$SDIR"/wallpapers/*.png "$WP_DIR/" 2>/dev/null || true
    
    # Scripts
    BIN="${TARGET_HOME}/.local/bin"
    sudo -u "$TARGET_USER" mkdir -p "$BIN"
    cp "$SDIR"/scripts/snowfox-* "$BIN/" 2>/dev/null || true
    chmod +x "$BIN"/snowfox-* 2>/dev/null || true
    
    # PATH Fix
    BASHRC="${TARGET_HOME}/.bashrc"
    grep -q '\.local/bin' "$BASHRC" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"

    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME"
    ok "Wallpapers und SnowFox-Scripts bereit"
}

finalize_system() {
    step "System-Abschluss"
    # Gruppen
    for g in video audio input seat render; do
        getent group "$g" &>/dev/null && usermod -aG "$g" "$TARGET_USER"
    done

    # greetd Config
    cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1
[default_session]
command = "tuigreet --time --remember --sessions /usr/share/wayland-sessions --cmd sway"
user = "greeter"
EOF
    systemctl enable greetd >> "$LOG" 2>&1
    
    # Pipewire
    sudo -u "$TARGET_USER" dbus-run-session systemctl --user enable pipewire pipewire-pulse wireplumber >> "$LOG" 2>&1 || true
    ok "Berechtigungen und Dienste konfiguriert"
}

finish() {
    echo -e "\n${P}${B}╔══════════════════════════════════════════════╗"
    echo -e "║    🦊 SnowFoxOS v2 erfolgreich installiert!  ║"
    echo -e "╚══════════════════════════════════════════════╝${N}"
    echo -e "\n${G}Hotkeys:${N}"
    echo -e "${O} Mod+Return${N}  → Terminal | ${O}Mod+R${N} → Apps | ${O}Mod+S${N} → Store"
    
    read -rp "Jetzt neu starten? [j/N]: " RB
    [[ "$RB" =~ ^[jJyY]$ ]] && reboot
}

# --- START ---
print_splash
check_requirements
update_system
install_sway_stack
install_apps
setup_configs
setup_scripts_and_assets
finalize_system
finish
