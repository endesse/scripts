#!/usr/bin/env bash
# fix-davinci-desktop-files.sh
# Fix DaVinci Resolve desktop entries:
# 1. /usr/share/applications/DaVinciResolve.desktop
#    - Prepend "progl " to Exec line
#    - Replace Icon with /opt/resolve/graphics/DV_Resolve.png
# 2. /usr/share/applications/DaVinciControlPanelsSetup.desktop
#    - Replace Icon with /opt/resolve/graphics/DV_Panels.png

set -euo pipefail

RESOLVE_FILE="/usr/share/applications/DaVinciResolve.desktop"
PANELS_FILE="/usr/share/applications/DaVinciControlPanelsSetup.desktop"

RESOLVE_ICON="/opt/resolve/graphics/DV_Resolve.png"
PANELS_ICON="/opt/resolve/graphics/DV_Panels.png"

# --- Ask for sudo if needed ---
if [[ "$EUID" -ne 0 ]]; then
  echo "🔒 This action requires root privileges."
  exec sudo "$0"
fi

fix_desktop() {
  local file="$1"
  local new_icon="$2"
  local prepend_progl="${3:-false}"

  if [[ ! -f "$file" ]]; then
    echo "❌ File not found: $file"
    return
  fi

  cp "$file" "$file.bak"
  echo "💾 Backup created: ${file}.bak"

  if [[ "$prepend_progl" == "true" ]]; then
    if grep -qE '^Exec=progl ' "$file"; then
      echo "⚠️  'progl' already present in Exec line of $(basename "$file")."
    else
      sed -i -E '0,/^Exec=/s|^(Exec=)(.*)|\1progl \2|' "$file"
      echo "✅ Added 'progl' to Exec line in $(basename "$file")."
    fi
  fi

  if grep -qE '^Icon=' "$file"; then
    sed -i -E "0,/^Icon=/s|^Icon=.*|Icon=${new_icon}|" "$file"
    echo "✅ Updated Icon path in $(basename "$file")."
  else
    echo "⚠️  No Icon line found, adding one to $(basename "$file")."
    echo "Icon=${new_icon}" >> "$file"
  fi

  echo "🔍 Final result for $(basename "$file"):"
  grep -E '^(Exec|Icon)=' "$file"
  echo
}

echo "🔧 Fixing DaVinci Resolve desktop entries..."
echo

fix_desktop "$RESOLVE_FILE" "$RESOLVE_ICON" true
fix_desktop "$PANELS_FILE" "$PANELS_ICON" false

echo "✅ All done!"
