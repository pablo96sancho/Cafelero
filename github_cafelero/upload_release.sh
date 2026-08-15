#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="${ROOT_DIR}/github_cafelero/releases"
DMG_FILE="${RELEASE_DIR}/Cafelero-Installer.dmg"
NOTES_FILE="${ROOT_DIR}/github_cafelero/release-notes.md"

if ! command -v gh >/dev/null 2>&1; then
    echo "❌ Falta GitHub CLI (gh). Instálalo primero: https://cli.github.com/"
    exit 1
fi

if [ ! -f "${DMG_FILE}" ]; then
    echo "❌ No existe el DMG listo para publicar: ${DMG_FILE}"
    echo "   Ejecuta primero: ./github_cafelero/prepare_dmg_for_release.sh"
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ No estás autenticado en GitHub con gh. Ejecuta: gh auth login"
    exit 1
fi

TAG="${1:-v1.0.0}"
REPO="${2:-$(git -C "${ROOT_DIR}" config --get remote.origin.url 2>/dev/null | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')}"

if [ -z "${REPO}" ]; then
    echo "❌ No se pudo detectar el repositorio remoto."
    echo "   Usa: ./github_cafelero/upload_release.sh v1.0.0 <usuario/repo>"
    exit 1
fi

echo "📦 Subiendo ${DMG_FILE} a GitHub Releases..."

gh release create "${TAG}" "${DMG_FILE}" \
  --repo "${REPO}" \
  --title "Cafelero ${TAG}" \
  --notes-file "${NOTES_FILE}" \
  --verify-tag

echo "✅ Release creada correctamente: ${TAG}"
echo "   Repositorio: ${REPO}"
