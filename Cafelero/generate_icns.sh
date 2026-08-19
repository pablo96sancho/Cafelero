#!/bin/bash
set -euo pipefail

# Path relative to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC_PNG="${ROOT_DIR}/docs/Cafelero ICONS/Cafelero ICON-iOS-Default-1024@1x.png"
ICONSET_DIR="${SCRIPT_DIR}/Cafelero.iconset"
OUT_ICNS="${SCRIPT_DIR}/Sources/Cafelero/AppIcon.icns"

if [ ! -f "$SRC_PNG" ]; then
    echo "Error: Source image not found at $SRC_PNG"
    exit 1
fi

echo "🎨 Generating iconset..."
mkdir -p "$ICONSET_DIR"

sips -z 16 16     "$SRC_PNG" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     "$SRC_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$SRC_PNG" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     "$SRC_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$SRC_PNG" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   "$SRC_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$SRC_PNG" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   "$SRC_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$SRC_PNG" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
sips -z 1024 1024 "$SRC_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null

echo "📦 Creating ICNS file..."
iconutil -c icns "$ICONSET_DIR" -o "$OUT_ICNS"

# Clean up
rm -rf "$ICONSET_DIR"
echo "✅ Icon generated at $OUT_ICNS"
