#!/bin/bash
# ============================================================
#  SnowFoxOS Power Menu
# ============================================================

CHOICE=$(printf "  Sperren\n  Abmelden\n  Neu starten\n  Herunterfahren\n  Abbrechen" \
  | wofi --dmenu \
         --prompt "Power" \
         --width 260 \
         --height 220 \
         --location center \
         --no-actions \
         --insensitive \
  | tr -d ' ')

case "$CHOICE" in
  Sperren)        swaylock -f -c 0a0a0a --ring-color 9B59B6 --key-hl-color E67E22 ;;
  Abmelden)       swaymsg exit ;;
  Neustarten)     systemctl reboot ;;
  Herunterfahren) systemctl poweroff ;;
  *)              exit 0 ;;
esac
