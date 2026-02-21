#!/bin/bash
# ============================================================
#  SnowFoxOS Store — App-Manager TUI
# ============================================================

PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

print_header() {
  clear
  echo -e "${PURPLE}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║          🦊 SnowFox Store v2                 ║"
  echo "  ║     App-Manager — APT + Flatpak              ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

show_menu() {
  echo -e "${WHITE}  Was möchtest du tun?${RESET}"
  echo ""
  echo -e "  ${PURPLE}[1]${RESET} App installieren (APT)"
  echo -e "  ${PURPLE}[2]${RESET} App deinstallieren (APT)"
  echo -e "  ${PURPLE}[3]${RESET} Flatpak App installieren"
  echo -e "  ${PURPLE}[4]${RESET} Flatpak App deinstallieren"
  echo -e "  ${PURPLE}[5]${RESET} Empfohlene Apps anzeigen"
  echo -e "  ${PURPLE}[6]${RESET} System aktualisieren"
  echo -e "  ${PURPLE}[7]${RESET} Installierte Apps anzeigen"
  echo -e "  ${ORANGE}[0]${RESET} Beenden"
  echo ""
}

show_recommended() {
  echo ""
  echo -e "${PURPLE}  ── BÜRO ─────────────────────────────────────${RESET}"
  echo -e "  ${DIM}APT:${RESET}     libreoffice"
  echo -e "  ${DIM}Flatpak:${RESET} org.libreoffice.LibreOffice"
  echo ""
  echo -e "${PURPLE}  ── GAMING ───────────────────────────────────${RESET}"
  echo -e "  ${DIM}Flatpak:${RESET} com.valvesoftware.Steam"
  echo -e "  ${DIM}Flatpak:${RESET} net.lutris.Lutris"
  echo -e "  ${DIM}Flatpak:${RESET} com.heroicgameslauncher.hgl"
  echo ""
  echo -e "${PURPLE}  ── MULTIMEDIA ───────────────────────────────${RESET}"
  echo -e "  ${DIM}APT:${RESET}     gimp"
  echo -e "  ${DIM}APT:${RESET}     inkscape"
  echo -e "  ${DIM}APT:${RESET}     vlc"
  echo -e "  ${DIM}APT:${RESET}     audacity"
  echo -e "  ${DIM}Flatpak:${RESET} org.gimp.GIMP"
  echo -e "  ${DIM}Flatpak:${RESET} org.blender.Blender"
  echo ""
  echo -e "${PURPLE}  ── KOMMUNIKATION ────────────────────────────${RESET}"
  echo -e "  ${DIM}Flatpak:${RESET} org.signal.Signal"
  echo -e "  ${DIM}Flatpak:${RESET} com.discordapp.Discord"
  echo -e "  ${DIM}Flatpak:${RESET} org.telegram.desktop"
  echo ""
  echo -e "${PURPLE}  ── ENTWICKLUNG ──────────────────────────────${RESET}"
  echo -e "  ${DIM}APT:${RESET}     git python3 nodejs npm gcc make"
  echo -e "  ${DIM}Flatpak:${RESET} com.jetbrains.IntelliJ-IDEA-Community"
  echo ""
  read -rp "$(echo -e "  ${DIM}Drücke Enter zum Fortfahren...${RESET}")" _
}

apt_install() {
  echo ""
  read -rp "$(echo -e "  ${ORANGE}Paketname (APT): ${RESET}")" pkg
  [[ -z "$pkg" ]] && return
  echo -e "  ${PURPLE}▶ Installiere: $pkg${RESET}"
  sudo apt-get install -y "$pkg" && \
    echo -e "  ${GREEN}✓ $pkg erfolgreich installiert!${RESET}" || \
    echo -e "  ${RED}✗ Fehler beim Installieren von $pkg${RESET}"
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

apt_remove() {
  echo ""
  read -rp "$(echo -e "  ${ORANGE}Paketname zum Entfernen: ${RESET}")" pkg
  [[ -z "$pkg" ]] && return
  read -rp "$(echo -e "  ${RED}  Wirklich entfernen? $pkg [j/N] ${RESET}")" confirm
  [[ "$confirm" =~ ^[jJ]$ ]] || return
  sudo apt-get remove -y "$pkg" && \
    echo -e "  ${GREEN}✓ $pkg entfernt${RESET}" || \
    echo -e "  ${RED}✗ Fehler${RESET}"
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

flatpak_install() {
  echo ""
  read -rp "$(echo -e "  ${ORANGE}Flatpak App-ID (z.B. com.valvesoftware.Steam): ${RESET}")" appid
  [[ -z "$appid" ]] && return
  flatpak install flathub "$appid" && \
    echo -e "  ${GREEN}✓ $appid installiert!${RESET}" || \
    echo -e "  ${RED}✗ Fehler${RESET}"
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

flatpak_remove() {
  echo ""
  read -rp "$(echo -e "  ${ORANGE}Flatpak App-ID zum Entfernen: ${RESET}")" appid
  [[ -z "$appid" ]] && return
  flatpak uninstall "$appid" && \
    echo -e "  ${GREEN}✓ $appid entfernt${RESET}" || \
    echo -e "  ${RED}✗ Fehler${RESET}"
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

system_update() {
  echo ""
  echo -e "  ${PURPLE}▶ System wird aktualisiert...${RESET}"
  sudo apt-get update && sudo apt-get upgrade -y
  echo -e "  ${PURPLE}▶ Flatpak Apps aktualisieren...${RESET}"
  flatpak update -y 2>/dev/null || true
  echo -e "  ${GREEN}✓ Alles aktuell!${RESET}"
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

list_installed() {
  echo ""
  echo -e "${PURPLE}  ── Manuell installierte APT-Pakete (letzte 20) ──${RESET}"
  grep " install " /var/log/dpkg.log 2>/dev/null | tail -20 | awk '{print "  "$5}' || echo "  (keine Daten)"
  echo ""
  echo -e "${PURPLE}  ── Installierte Flatpak Apps ──${RESET}"
  flatpak list --app 2>/dev/null | awk '{print "  "$1}' || echo "  (keine Flatpak Apps)"
  echo ""
  read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
}

# Main Loop
while true; do
  print_header
  show_menu
  read -rp "$(echo -e "  ${ORANGE}Auswahl: ${RESET}")" choice
  case "$choice" in
    1) apt_install ;;
    2) apt_remove ;;
    3) flatpak_install ;;
    4) flatpak_remove ;;
    5) print_header; show_recommended ;;
    6) system_update ;;
    7) print_header; list_installed ;;
    0|q|Q) echo -e "  ${DIM}Tschüss! 🦊${RESET}"; exit 0 ;;
    *) echo -e "  ${RED}Ungültige Auswahl${RESET}"; sleep 1 ;;
  esac
done
