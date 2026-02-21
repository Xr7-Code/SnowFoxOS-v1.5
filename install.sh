#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                   SnowFoxOS v2 — Installer                       ║
# ║               Minimal. Schnell. Schön.                           ║
# ╚══════════════════════════════════════════════════════════════════╝

set -e
LOG="/tmp/snowfoxos_install.log"

P='\033[0;35m' O='\033[0;33m' G='\033[0;32m' R='\033[0;31m'
B='\033[1m' D='\033[2m' N='\033[0m'

log()  { echo -e "${P}[SnowFox]${N} $1" | tee -a "$LOG"; }
ok()   { echo -e "${G}[  OK  ]${N} $1" | tee -a "$LOG"; }
err()  { echo -e "${R}[ ERR  ]${N} $1" | tee -a "$LOG"; }
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
    [[ $EUID -ne 0 ]] && { err "Bitte mit sudo ausführen: sudo ./install.sh"; exit 1; }
    ok "Root-Rechte OK"

    [[ ! -f /etc/debian_version ]] && { err "Nur für Debian 12!"; exit 1; }
    ok "Debian erkannt: $(cat /etc/debian_version)"

    ping -c1 -W3 8.8.8.8 &>/dev/null || { err "Keine Internetverbindung."; exit 1; }
    ok "Internet OK"

    FREE=$(df -BG / | awk 'NR==2{print $4}' | tr -d G)
    [[ "$FREE" -lt 8 ]] && { err "Zu wenig Speicher: ${FREE}GB (min 8GB)"; exit 1; }
    ok "Speicher OK: ${FREE}GB frei"

    if [[ -n "$SUDO_USER" ]]; then
        TARGET_USER="$SUDO_USER"
    else
        TARGET_USER=$(who | head -1 | awk '{print $1}')
    fi
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    ok "Ziel-User: ${TARGET_USER} (${TARGET_HOME})"
    export TARGET_USER TARGET_HOME
}

update_system() {
    step "System aktualisieren"
    apt update -qq | tee -a "$LOG"
    ok "Paketlisten OK"
    apt upgrade -y -qq | tee -a "$LOG"
    ok "System aktuell"
    apt install -y --no-install-recommends \
        curl wget git ca-certificates gnupg apt-transport-https \
        software-properties-common dialog xdg-utils xdg-user-dirs \
        dbus-x11 polkit >> "$LOG" 2>&1
    ok "Basis-Pakete installiert"
}

install_sway_stack() {
    step "Sway Wayland-Stack"
    apt install -y --no-install-recommends \
        sway swaybg swaylock swayidle \
        waybar wofi foot mako-notifier \
        grim slurp wl-clipboard \
        xwayland \
        brightnessctl \
        pipewire pipewire-pulse wireplumber \
        network-manager network-manager-gnome \
        xdg-desktop-portal xdg-desktop-portal-wlr \
        >> "$LOG" 2>&1
    ok "Sway Stack installiert"
}

install_apps() {
    step "Apps installieren"
    apt install -y --no-install-recommends \
        firefox-esr \
        thunar thunar-archive-plugin thunar-volman \
        neovim \
        galculator \
        imv \
        btop \
        file-roller \
        gvfs gvfs-backends udisks2 \
        papirus-icon-theme \
        fonts-noto fonts-noto-color-emoji \
        fontconfig \
        >> "$LOG" 2>&1
    ok "Basis-Apps installiert"

    # Fonts
    apt install -y fonts-inter >> "$LOG" 2>&1 || info "Inter Font nicht im Repo, überspringe"
    apt install -y fonts-jetbrains-mono >> "$LOG" 2>&1 || info "JetBrains Mono nicht im Repo, überspringe"

    # VSCodium
    log "Installiere VSCodium..."
    if ! command -v codium &>/dev/null; then
        curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
            | gpg --dearmor > /usr/share/keyrings/vscodium-archive-keyring.gpg 2>/dev/null
        echo "deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] \
https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main" \
            > /etc/apt/sources.list.d/vscodium.list
        apt update -qq >> "$LOG" 2>&1
        apt install -y codium >> "$LOG" 2>&1 && ok "VSCodium installiert" || info "VSCodium fehlgeschlagen"
    else
        ok "VSCodium bereits vorhanden"
    fi

    # greetd
    log "Installiere greetd..."
    apt install -y greetd >> "$LOG" 2>&1 && {
        # tuigreet binary
        if ! command -v tuigreet &>/dev/null; then
            TG_URL="https://github.com/apognu/tuigreet/releases/download/0.9.0/tuigreet-0.9.0-amd64"
            curl -fsSL "$TG_URL" -o /usr/bin/tuigreet 2>/dev/null && chmod +x /usr/bin/tuigreet && \
                ok "tuigreet installiert" || info "tuigreet Download fehlgeschlagen"
        fi
        # Sway desktop entry
        mkdir -p /usr/share/wayland-sessions
        cat > /usr/share/wayland-sessions/sway.desktop << 'DESK'
[Desktop Entry]
Name=Sway
Comment=Wayland compositor
Exec=sway
Type=Application
DESK
        ok "greetd konfiguriert"
    } || info "greetd nicht verfügbar"
}

setup_flatpak() {
    step "Flatpak einrichten"
    apt install -y flatpak >> "$LOG" 2>&1
    sudo -u "$TARGET_USER" flatpak remote-add --user --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG" 2>&1 || \
    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG" 2>&1
    ok "Flathub eingerichtet — Steam, Discord etc. jetzt installierbar via Mod+S"
}

setup_configs() {
    step "Configs einrichten"
    SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CFG="${TARGET_HOME}/.config"

    sudo -u "$TARGET_USER" mkdir -p \
        "$CFG/sway" "$CFG/waybar" "$CFG/wofi" \
        "$CFG/foot" "$CFG/mako" "$CFG/nvim" \
        "$CFG/gtk-3.0" "$CFG/gtk-4.0"

    cp "$SDIR/configs/sway/config"         "$CFG/sway/config"
    cp "$SDIR/configs/waybar/config"        "$CFG/waybar/config"
    cp "$SDIR/configs/waybar/style.css"     "$CFG/waybar/style.css"
    cp "$SDIR/configs/wofi/config"          "$CFG/wofi/config"
    cp "$SDIR/configs/wofi/style.css"       "$CFG/wofi/style.css"
    cp "$SDIR/configs/foot/foot.ini"        "$CFG/foot/foot.ini"
    cp "$SDIR/configs/mako/config"          "$CFG/mako/config"
    cp "$SDIR/configs/neovim/init.lua"      "$CFG/nvim/init.lua"
    cp "$SDIR/configs/gtk/settings.ini"     "$CFG/gtk-3.0/settings.ini"
    cp "$SDIR/configs/gtk/settings.ini"     "$CFG/gtk-4.0/settings.ini"

    chown -R "${TARGET_USER}:${TARGET_USER}" \
        "$CFG/sway" "$CFG/waybar" "$CFG/wofi" "$CFG/foot" \
        "$CFG/mako" "$CFG/nvim" "$CFG/gtk-3.0" "$CFG/gtk-4.0"

    ok "Configs installiert"
}

setup_wallpapers() {
    step "Wallpaper einrichten"
    SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WP_DIR="${TARGET_HOME}/Pictures/SnowFoxOS"
    sudo -u "$TARGET_USER" mkdir -p "$WP_DIR"
    cp "$SDIR/wallpapers/"*.png "$WP_DIR/" 2>/dev/null || true
    chown -R "${TARGET_USER}:${TARGET_USER}" "$WP_DIR"
    ok "Wallpaper installiert → $WP_DIR"
}

setup_scripts() {
    step "SnowFox Scripts"
    SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BIN="${TARGET_HOME}/.local/bin"
    sudo -u "$TARGET_USER" mkdir -p "$BIN"

    cp "$SDIR/scripts/snowfox-store.sh" "$BIN/snowfox-store"
    cp "$SDIR/scripts/snowfox-wifi.sh"  "$BIN/snowfox-wifi"
    cp "$SDIR/scripts/snowfox-power.sh" "$BIN/snowfox-power"
    chmod +x "$BIN/snowfox-store" "$BIN/snowfox-wifi" "$BIN/snowfox-power"
    chown -R "${TARGET_USER}:${TARGET_USER}" "$BIN"

    # PATH eintragen
    BASHRC="${TARGET_HOME}/.bashrc"
    grep -q '\.local/bin' "$BASHRC" 2>/dev/null || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"

    ok "Scripts installiert"
}

setup_user_groups() {
    step "User-Gruppen"
    for g in video audio input seat render; do
        getent group "$g" &>/dev/null && usermod -aG "$g" "$TARGET_USER" 2>/dev/null && \
            info "→ Gruppe '$g'" || true
    done
    ok "Gruppen eingerichtet"
}

enable_greetd() {
    step "Login-Manager"
    if systemctl list-unit-files greetd.service &>/dev/null 2>&1; then
        SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        cp "$SDIR/configs/greetd/config.toml" /etc/greetd/config.toml 2>/dev/null || true
        for dm in gdm gdm3 sddm lightdm lxdm; do
            systemctl disable "$dm" >> "$LOG" 2>&1 || true
        done
        systemctl enable greetd >> "$LOG" 2>&1
        ok "greetd aktiviert"
    else
        info "greetd nicht verfügbar — richte Auto-Login via .bash_profile ein"
        PROFILE="${TARGET_HOME}/.bash_profile"
        grep -q 'exec sway' "$PROFILE" 2>/dev/null || cat >> "$PROFILE" << 'PROF'

# SnowFoxOS: Sway auf TTY1 automatisch starten
if [ "$(tty)" = "/dev/tty1" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    exec sway
fi
PROF
        chown "${TARGET_USER}:${TARGET_USER}" "$PROFILE"
        ok "Auto-Login eingerichtet (TTY1 → Sway)"
    fi
}

setup_audio() {
    step "Audio (PipeWire)"
    systemctl --global enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
    ok "PipeWire aktiviert"
}

finish() {
    echo ""
    echo -e "${P}${B}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║                                              ║"
    echo "  ║  🦊  SnowFoxOS v2 erfolgreich installiert!   ║"
    echo "  ║                                              ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${N}"
    echo -e "${G}Fertig! Das musst du wissen:${N}\n"
    echo -e "${O}  Mod+Return${N}  → Terminal"
    echo -e "${O}  Mod+R${N}       → App-Launcher"
    echo -e "${O}  Mod+S${N}       → SnowFox Store (Steam, Discord...)"
    echo -e "${O}  Mod+N${N}       → WiFi"
    echo -e "${O}  Mod+,${N}       → Power Menu"
    echo -e "\n${D}  Log: ${LOG}${N}\n"
    read -rp "Jetzt neu starten? [j/N]: " RB
    [[ "$RB" =~ ^[jJyY]$ ]] && systemctl reboot
}

print_splash
echo -e "${D}Log: ${LOG}${N}\n"
sleep 1

check_requirements
update_system
install_sway_stack
install_apps
setup_flatpak
setup_configs
setup_wallpapers
setup_scripts
setup_user_groups
enable_greetd
setup_audio
finish
