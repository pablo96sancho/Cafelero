# GitHub para Cafelero

Esta carpeta sirve para preparar y publicar el DMG de Cafelero en GitHub Releases.

## Estructura

- `prepare_dmg_for_release.sh`: genera o valida que exista el DMG listo para publicación.
- `upload_release.sh`: sube el archivo `.dmg` a un release de GitHub usando `gh`.
- `release-notes.md`: texto base para el release.
- `.gitignore`: evita subir artefactos generados dentro de esta carpeta.
- `.github/workflows/release-dmg.yml`: workflow opcional para publicar automáticamente al hacer un tag.

## Uso rápido

1. Desde la raíz del proyecto, genera el DMG:

```bash
./create_dmg.sh
```

2. Prepara el artefacto para publicación:

```bash
./github_cafelero/prepare_dmg_for_release.sh
```

3. Sube el DMG a GitHub:

```bash
./github_cafelero/upload_release.sh v1.0.0
```

Si quieres usar el workflow automático, haz un tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Requisitos

- GitHub CLI instalado: `gh`
- Autenticado con GitHub: `gh auth login`
- Repositorio GitHub remoto configurado

## Nota

El archivo final para publicar es:

```bash
./github_cafelero/releases/Cafelero-Installer.dmg
```
