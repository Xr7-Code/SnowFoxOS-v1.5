#!/bin/bash
# ============================================================
#  SnowFoxOS Update Script
# ============================================================

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
RESET='\033[0m'

echo -e "${PURPLE}  🦊 SnowFoxOS Update${RESET}"
echo ""
echo -e "${WHITE}  ▶ System-Pakete aktualisieren...${RESET}"
sudo apt-get update && sudo apt-get upgrade -y
echo ""
echo -e "${WHITE}  ▶ Flatpak Apps aktualisieren...${RESET}"
flatpak update -y 2>/dev/null || true
echo ""
echo -e "${GREEN}  ✓ Alles aktuell! 🦊${RESET}"
