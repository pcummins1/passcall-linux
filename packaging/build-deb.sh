#!/bin/sh
# Builds dist/passcall-window_<version>_all.deb from this checkout. Needs dpkg-deb and
# fakeroot (both in Debian/Ubuntu by default). No build dependencies otherwise.
set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n 's/^VERSION="\(.*\)"/\1/p' "$HERE/bin/passcall-window")"
PKG="passcall-window"
ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT
D="$ROOT/$PKG"
mkdir -p "$D/DEBIAN" "$D/usr/bin" "$D/usr/share/applications" "$D/usr/share/icons/hicolor/512x512/apps" \
  "$D/usr/share/metainfo" "$D/usr/lib/systemd/user" "$D/usr/share/doc/$PKG"
install -m 755 "$HERE/bin/passcall-window" "$D/usr/bin/passcall-window"
install -m 644 "$HERE/share/io.passcall.Window.desktop" "$D/usr/share/applications/"
install -m 644 "$HERE/share/io.passcall.Window.png" "$D/usr/share/icons/hicolor/512x512/apps/"
install -m 644 "$HERE/share/io.passcall.Window.metainfo.xml" "$D/usr/share/metainfo/"
# The home-folder install runs the launcher from ~/.local/bin; the package puts it in /usr/bin.
sed 's#%h/.local/bin/passcall-window#/usr/bin/passcall-window#' "$HERE/share/passcall-window.service" > "$D/usr/lib/systemd/user/passcall-window.service"
chmod 644 "$D/usr/lib/systemd/user/passcall-window.service"
install -m 644 "$HERE/README.md" "$D/usr/share/doc/$PKG/README.md"
{
  echo "Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/"
  echo "Upstream-Name: $PKG"
  echo "Source: https://github.com/pcummins1/passcall-linux"
  echo ""
  echo "Files: *"
  echo "Copyright: 2026 PassCall LLC"
  echo "License: MIT"
  sed 's/^/ /; s/^ $/ ./' "$HERE/LICENSE"
} > "$D/usr/share/doc/$PKG/copyright"
chmod 644 "$D/usr/share/doc/$PKG/copyright"
cat > "$D/DEBIAN/control" <<CONTROL
Package: $PKG
Version: $VERSION
Section: net
Priority: optional
Architecture: all
Maintainer: PassCall LLC <help@passcall.io>
Recommends: chromium | chromium-browser | google-chrome-stable | brave-browser | firefox
Suggests: systemd
Homepage: https://passcall.io/linux/
Installed-Size: $(du -sk "$D/usr" | cut -f1)
Description: PassCall window launcher: a window between homes
 PassCall turns a display with a camera into a window between two homes:
 when you and a friend both walk past your screens at the same time, the
 window opens and you see each other. No calls to make, no feed, no ads,
 no recording.
 .
 This package opens the PassCall web app in a browser window of its own
 (Chromium, Chrome, Brave or Firefox), keeps the machine awake while the
 window is open, and offers a kiosk mode that starts full screen at login:
 systemctl --user enable --now passcall-window.service
CONTROL
cat > "$D/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
exit 0
POSTINST
cp "$D/DEBIAN/postinst" "$D/DEBIAN/postrm"
chmod 755 "$D/DEBIAN/postinst" "$D/DEBIAN/postrm"
mkdir -p "$HERE/dist"
OUT="$HERE/dist/${PKG}_${VERSION}_all.deb"
fakeroot dpkg-deb --build "$D" "$OUT" >/dev/null
echo "$OUT"
