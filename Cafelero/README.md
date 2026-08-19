# ☕️ Cafelero

> **Mantén tu Mac despierto con un solo clic.**

Cafelero es una aplicación ligera e intuitiva para la barra de menú de macOS diseñada para evitar que tu equipo entre en modo de reposo o active el salvapantallas mientras trabajas, presentas o descargas archivos.

[![Download DMG](https://img.shields.io/github/v/release/pablo96sancho/Cafelero?label=Descargar%20DMG&color=007AFF&logo=apple)](https://github.com/pablo96sancho/Cafelero/releases/latest)

---

## 🚀 Características

- ☕️ **Activación rápida:** Enciende o apaga la prevención de reposo desde la barra de menú.
- ⏱️ **Temporizador personalizado:** Define duraciones específicas para mantener el sistema despierto.
- 💻 **Nativo y ligero:** Consumo mínimo de recursos y diseño integrado con macOS.

---

## 📸 Captura de pantalla

![Cafelero Preview](docs/screenshot.png)

---

## 📦 Instalación

1. Descarga la última versión desde [GitHub Releases](https://github.com/pablo96sancho/Cafelero/releases/latest).
2. Abre el archivo `Cafelero-Installer.dmg`.
3. Arrastra **Cafelero.app** a tu carpeta de **Aplicaciones**.
4. ¡Listo! Ejecuta la app desde la barra de menú.

---

## 🛠️ Desarrollo

### Requisitos

- macOS 13 o superior
- Xcode 15+ o Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9+

### Compilar y probar

```bash
cd Cafelero
chmod +x build_and_run.sh
./build_and_run.sh
```

Esto compila el paquete con SwiftPM, lo empaqueta como `Cafelero.app` dentro de `.build/`, lo firma ad-hoc y lo lanza.

### Estructura del proyecto

```text
Cafelero/
├── Package.swift
├── build_and_run.sh
├── README.md
├── create_dmg.sh
└── Sources/
    └── Cafelero/
        ├── CafeleroApp.swift
        ├── AntiSleepManager.swift
        ├── MenuBarView.swift
        └── Info.plist
```

---

## 🔒 Permisos

Si activas el respaldo de tecla neutra, macOS pedirá permiso de **Accesibilidad** la primera vez que se envíe el evento `CGEvent`. Puedes concederlo en:

**Ajustes del Sistema → Privacidad y seguridad → Accesibilidad**

Si solo usas la assertion de IOKit, no se necesita ningún permiso especial.
