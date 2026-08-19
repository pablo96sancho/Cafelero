#!/bin/bash
#
# build_and_run.sh
#
# Compila Cafelero con Swift Package Manager, la empaqueta a mano como
# un .app válido de macOS (necesario para que LSUIElement e IOKit
# funcionen correctamente) y la lanza.
#
# Uso:
#   chmod +x build_and_run.sh
#   ./build_and_run.sh
#
# Requisitos: Xcode Command Line Tools instaladas (swift --version debe
# funcionar) y macOS 13+.

set -e

APP_NAME="Cafelero"
BUILD_CONFIG="release"
BUNDLE_DIR=".build/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🔨 Compilando ${APP_NAME} (${BUILD_CONFIG})..."
swift build -c "${BUILD_CONFIG}"

BIN_PATH=$(swift build -c "${BUILD_CONFIG}" --show-bin-path)/${APP_NAME}

if [ ! -f "${BIN_PATH}" ]; then
    echo "❌ No se encontró el binario compilado en ${BIN_PATH}"
    exit 1
fi

echo "📦 Empaquetando como ${APP_NAME}.app..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"
cp "Sources/${APP_NAME}/Info.plist" "${CONTENTS_DIR}/Info.plist"
cp "Sources/${APP_NAME}/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"

# Firma ad-hoc: necesaria en Macs con Apple Silicon para poder ejecutar
# el binario y para que macOS conceda los permisos correspondientes
# (ej. Accesibilidad, si se usa el respaldo de CGEvent).
echo "✍️  Firmando ad-hoc..."
codesign --force --deep --sign - "${BUNDLE_DIR}"

echo "🚀 Lanzando ${APP_NAME}..."
open "${BUNDLE_DIR}"

echo ""
echo "✅ Listo. Busca el icono de la taza de café en la barra de menú."
echo ""
echo "ℹ️  Si activas el respaldo de tecla neutra (F15) en Configuración,"
echo "   macOS te pedirá permiso de Accesibilidad la primera vez:"
echo "   Ajustes del Sistema → Privacidad y seguridad → Accesibilidad"
echo "   → activa ${APP_NAME}."
echo ""
echo "ℹ️  Para mover la app a /Applications:"
echo "   cp -R \"${BUNDLE_DIR}\" /Applications/"
