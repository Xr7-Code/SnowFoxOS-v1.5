#!/bin/bash
# ============================================================
#  SnowFoxOS WiFi-Manager (nmcli TUI)
# ============================================================

PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

clear
echo -e "${PURPLE}  ╔═══════════════════════════════════╗"
echo -e "  ║     🦊 SnowFoxOS WiFi-Manager    ║"
echo -e "  ╚═══════════════════════════════════╝${RESET}"
echo ""

# Aktueller Status
current=$(nmcli -t -f NAME,TYPE,STATE con show --active 2>/dev/null | grep -i "wifi" | head -1 | cut -d: -f1)
if [[ -n "$current" ]]; then
  echo -e "  ${GREEN}✓ Verbunden mit: $current${RESET}"
else
  echo -e "  ${DIM}  Keine WLAN-Verbindung aktiv${RESET}"
fi
echo ""

echo -e "${WHITE}  [1] Verfügbare Netzwerke anzeigen"
echo -e "  [2] Mit Netzwerk verbinden"
echo -e "  [3] Verbindung trennen"
echo -e "  [4] Bekannte Netzwerke anzeigen"
echo -e "${ORANGE}  [0] Beenden${RESET}"
echo ""

read -rp "$(echo -e "  ${ORANGE}Auswahl: ${RESET}")" choice

case "$choice" in
  1)
    echo ""
    echo -e "${PURPLE}  ── Verfügbare Netzwerke ────────────────${RESET}"
    nmcli device wifi list
    read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
    ;;
  2)
    echo ""
    echo -e "${PURPLE}  ── Verfügbare Netzwerke ────────────────${RESET}"
    nmcli device wifi list
    echo ""
    read -rp "$(echo -e "  ${ORANGE}SSID (Netzwerkname): ${RESET}")" ssid
    [[ -z "$ssid" ]] && exit 0
    read -rsp "$(echo -e "  ${ORANGE}Passwort (leer = kein): ${RESET}")" pass
    echo ""
    if [[ -n "$pass" ]]; then
      nmcli device wifi connect "$ssid" password "$pass" && \
        echo -e "  ${GREEN}✓ Verbunden mit $ssid!${RESET}" || \
        echo -e "  ${RED}✗ Verbindung fehlgeschlagen${RESET}"
    else
      nmcli device wifi connect "$ssid" && \
        echo -e "  ${GREEN}✓ Verbunden mit $ssid!${RESET}" || \
        echo -e "  ${RED}✗ Verbindung fehlgeschlagen${RESET}"
    fi
    read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
    ;;
  3)
    nmcli device disconnect wlan0 2>/dev/null || nmcli device disconnect wlp2s0 2>/dev/null
    echo -e "  ${GREEN}✓ Verbindung getrennt${RESET}"
    sleep 1
    ;;
  4)
    echo ""
    echo -e "${PURPLE}  ── Bekannte Netzwerke ──────────────────${RESET}"
    nmcli connection show | grep -i "wifi\|802-11"
    read -rp "$(echo -e "  ${DIM}Drücke Enter...${RESET}")" _
    ;;
  0|*) exit 0 ;;
esac
