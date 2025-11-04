#!/usr/bin/env bash
# fix-resolve-desktop.sh
# Fix DaVinci Resolve .desktop entry:
# - Prepend "progl " to Exec line
# - Replace icon path with /opt/resolve/graphics/DV_Resolve.png

set -euo pipefail

DESKTOP_FILE="/usr/share/applications/DaVinciResolve.desktop"
ICON_PATH="/opt/resolve/graphics/DV_Resolve.png"

# --- Ask for sudo if needed ---
if [[ "$EUID" -ne 0 ]]; then
  echo "🔒 This action requires root privileges."
  exec sudo "$0"
fi

# --- Validation ---
if [[ ! -f "$DESKTOP_FILE" ]]; then
  echo "❌ File not found: $DESKTOP_FILE"
  exit 1
fi

# --- Backup before editing ---
cp "$DESKTOP_FILE" "$DESKTOP_FILE.bak"
echo "💾 Backup created at: ${DESKTOP_FILE}.bak"

# --- Update Exec line (prepend 'progl ' if missing) ---
if grep -qE '^Exec=progl ' "$DESKTOP_FILE"; then
  echo "⚠️  'progl' already present in Exec line. Skipping."
else
  sed -i -E '0,/^Exec=/s|^(Exec=)(.*)|\1progl \2|' "$DESKTOP_FILE"
  echo "✅ Updated Exec line to include 'progl'."
fi

# --- Update Icon line ---
if grep -qE '^Icon=' "$DESKTOP_FILE"; then
  sed -i -E "0,/^Icon=/s|^Icon=.*|Icon=${ICON_PATH}|" "$DESKTOP_FILE"
  echo "✅ Updated icon path."
else
  echo "⚠️  No Icon line found, adding one."
  echo "Icon=${ICON_PATH}" >> "$DESKTOP_FILE"
fi

# --- Show result ---
echo
echo "🔍 Final result:"
grep -E '^(Exec|Icon)=' "$DESKTOP_FILE"

