#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Cafelero"
SOURCE_DMG="${ROOT_DIR}/Cafelero/${APP_NAME}-Installer.dmg"
RELEASE_DIR="${ROOT_DIR}/github_cafelero/releases"
DEST_DMG="${RELEASE_DIR}/${APP_NAME}-Installer.dmg"

mkdir -p "${RELEASE_DIR}"

if [ ! -f "${SOURCE_DMG}" ]; then
    echo "📦 El DMG no existe todavía. Generándolo desde la app..."
    cd "${ROOT_DIR}/Cafelero"

    if [ -f "./build_and_run.sh" ]; then
        ./build_and_run.sh
    fi

    if [ -f "./create_dmg.sh" ]; then
        ./create_dmg.sh
    fi
fi

if [ ! -f "${SOURCE_DMG}" ]; then
    echo "❌ No se pudo generar el DMG. Comprueba la compilación y la firma de la app."
    exit 1
fi

cp -f "${SOURCE_DMG}" "${DEST_DMG}"

ls -lh "${DEST_DMG}"
echo "✅ DMG listo para subir a GitHub: ${DEST_DMG}"
