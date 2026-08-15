#!/bin/bash
#
# create_dmg.sh
#
# Genera un .dmg instalable para Cafelero usando ÚNICAMENTE hdiutil,
# sin AppleScript ni control del Finder (evita el error -1728, que
# aparece cuando Finder no encuentra/reconoce el disco montado al
# intentar maquetar la ventana mediante scripting).
#
# El resultado es un DMG funcional y directo: al abrirlo se ve
# Cafelero.app junto a un acceso directo a /Applications, en vista
# de iconos por defecto del Finder (sin posiciones ni fondo
# personalizados).
#
# Uso:
#   chmod +x create_dmg.sh
#   ./create_dmg.sh

set -euo pipefail

# ── Configuración ────────────────────────────────────────────────────
APP_NAME="Cafelero"
APP_PATH=".build/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-Installer.dmg"
VOLUME_NAME="Instalar Cafelero"
STAGING_DIR=".dmg_staging"
TMP_DMG="${APP_NAME}-tmp.dmg"

# ── Limpieza garantizada (éxito o fallo) ────────────────────────────
# El trap se registra ya al principio: si algo falla en cualquier
# punto posterior, el staging y el DMG temporal se eliminan igual.
cleanup() {
    rm -rf "${STAGING_DIR}"
    rm -f "${TMP_DMG}"
}
trap cleanup EXIT

# ── 1) Comprobar que la app compilada existe ────────────────────────
if [ ! -d "${APP_PATH}" ]; then
    echo "❌ No se encontró ${APP_PATH}"
    echo ""
    echo "   Antes de generar el DMG tienes que compilar la app:"
    echo "     ./build_and_run.sh"
    echo ""
    exit 1
fi

echo "✅ App encontrada en ${APP_PATH}"

# ── 2) Preparar el staging con la app + acceso a Applications ──────
rm -f "${DMG_NAME}"
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

cp -R "${APP_PATH}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

echo "📁 Staging listo en ${STAGING_DIR}/ (app + symlink a /Applications)"

# ── 3) Crear el DMG comprimido directamente con hdiutil ─────────────
# -srcfolder + -format UDZO genera la imagen final ya comprimida en
# un solo paso, sin necesidad de montar nada ni de convertir después.
# Esto es lo que elimina por completo la dependencia de Finder/
# AppleScript: nunca hay un volumen montado que maquetar a mano.
echo "📦 Creando ${DMG_NAME}..."
hdiutil create \
    -srcfolder "${STAGING_DIR}" \
    -volname "${VOLUME_NAME}" \
    -fs HFS+ \
    -format UDZO \
    -imagekey zlib-level=9 \
    -ov \
    -quiet \
    "${DMG_NAME}"

# ── 4) Verificación final ───────────────────────────────────────────
if [ -f "${DMG_NAME}" ]; then
    SIZE_HUMAN=$(du -h "${DMG_NAME}" | cut -f1)
    echo ""
    echo "✅ DMG creado correctamente: ${DMG_NAME} (${SIZE_HUMAN})"
    echo ""
    echo "   Puedes distribuirlo tal cual. El usuario deberá:"
    echo "   1) Abrir ${DMG_NAME}"
    echo "   2) Arrastrar ${APP_NAME}.app sobre el acceso directo a Applications"
    echo "   3) Expulsar el volumen \"${VOLUME_NAME}\""
else
    echo "❌ Algo falló: no se generó ${DMG_NAME}"
    exit 1
fi

# La limpieza final (staging + DMG temporal si existiera) la hace
# automáticamente el trap al salir del script.
