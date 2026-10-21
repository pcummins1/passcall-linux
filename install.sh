#!/bin/sh
# Installs PassCall for Linux into your home folder. No root needed.
#
#   ./install.sh            app mode: PassCall appears in your application menu
#   ./install.sh --kiosk    kiosk mode: the window opens full screen at every login
#   ./install.sh --remove   takes it all out again
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"; APPS="$HOME/.local/share/applications"; ICONS="$HOME/.local/share/icons/hicolor/512x512/apps"
AUTOSTART="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"; UNITS="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

if [ "${1:-}" = "--remove" ]; then
  systemctl --user disable --now passcall-window.service 2>/dev/null || true
  rm -f "$BIN/passcall-window" "$APPS/passcall.desktop" "$AUTOSTART/passcall-kiosk.desktop" "$UNITS/passcall-window.service" "$ICONS/passcall.png"
  systemctl --user daemon-reload 2>/dev/null || true
  echo "PassCall removed. Your sign-in and camera choice stay in ~/.config/passcall-window; delete that folder to forget them."
  exit 0
fi

mkdir -p "$BIN" "$APPS" "$ICONS"
install -m 755 "$HERE/bin/passcall-window" "$BIN/passcall-window"
install -m 644 "$HERE/share/passcall.png" "$ICONS/passcall.png"
install -m 644 "$HERE/share/passcall.desktop" "$APPS/passcall.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

if [ "${1:-}" = "--kiosk" ]; then
  mkdir -p "$AUTOSTART" "$UNITS"
  install -m 644 "$HERE/share/passcall-window.service" "$UNITS/passcall-window.service"
  if systemctl --user daemon-reload 2>/dev/null && systemctl --user enable passcall-window.service 2>/dev/null; then
    echo "Kiosk mode: the PassCall window will open full screen at every login (systemd user service)."
  else
    install -m 644 "$HERE/share/passcall-kiosk.desktop" "$AUTOSTART/passcall-kiosk.desktop"
    echo "Kiosk mode: the PassCall window will open full screen at every login (autostart entry)."
  fi
  echo "Start it now with:  passcall-window --kiosk   (or log out and in)."
else
  echo "Installed. Open PassCall from your application menu, or run: passcall-window"
fi
case ":$PATH:" in *":$BIN:"*) ;; *) echo "Note: add $BIN to your PATH to run passcall-window from a terminal.";; esac
echo "First run: sign in, then allow the camera and microphone when the browser asks. It remembers both."
