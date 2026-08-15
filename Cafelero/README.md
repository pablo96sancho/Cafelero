# Cafelero ☕️

App nativa de macOS para la barra de menú que evita que tu Mac entre en reposo,
inspirada en Caffeinated / Amphetamine.

## Estructura del proyecto

```
Cafelero/
├── Package.swift
├── build_and_run.sh
├── README.md
└── Sources/
    └── Cafelero/
        ├── CafeleroApp.swift      # Punto de entrada (MenuBarExtra + AppDelegate)
        ├── AntiSleepManager.swift # Lógica anti-reposo (IOKit + respaldo CGEvent)
        ├── MenuBarView.swift      # UI del popover (toggle, duración, ajustes)
        └── Info.plist             # LSUIElement = true (agent app, sin Dock)
```

## Requisitos

- macOS 13 (Ventura) o superior
- Xcode 15+ o Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9+

## Cómo compilar y probar (opción rápida, sin Xcode)

```bash
cd Cafelero
chmod +x build_and_run.sh
./build_and_run.sh
```

Esto compila el paquete con SwiftPM, lo empaqueta como `Cafelero.app` dentro de
`.build/`, lo firma ad-hoc y lo lanza. El icono de la taza aparecerá en la
barra de menú (no verás nada en el Dock, es intencionado).

Para instalarlo de forma permanente:

```bash
cp -R .build/Cafelero.app /Applications/
```

## Cómo abrirlo en Xcode (opción recomendada para desarrollo/depuración)

1. Abre Xcode → **File → Open...** → selecciona la carpeta `Cafelero` (la que
   contiene `Package.swift`). Xcode reconocerá el Swift Package automáticamente.
2. Selecciona el esquema **Cafelero** y el destino **My Mac**.
3. Antes de compilar, ve a **Target "Cafelero" → Info** y asegúrate de que:
   - `LSUIElement` = `YES` (ya viene en `Info.plist`, pero SwiftPM en Xcode a
     veces requiere fijarlo también en el "Info" tab del target).
   - En **Signing & Capabilities**, asigna tu Team para firmar la app
     (necesario para que persista el permiso de Accesibilidad entre
     ejecuciones).
4. Pulsa Run (⌘R).

> Si prefieres un proyecto `.xcodeproj` tradicional en lugar de SwiftPM:
> crea un nuevo proyecto **macOS → App**, marca "SwiftUI" como interfaz,
> desmarca "Storyboard", y sustituye los archivos generados por los de
> `Sources/Cafelero/`. Añade `LSUIElement = YES` en el Info tab.

## Funcionalidad

- **Anti-reposo nativo**: usa `IOPMAssertionCreateWithName` con
  `kIOPMAssertionTypeNoDisplaySleep`, que evita tanto que el sistema entre en
  reposo como que se apague la pantalla.
- **Respaldo opcional**: si lo activas en Configuración, simula cada 59s una
  pulsación de la tecla F15 (sin efecto visible) vía `CGEvent`, útil como
  refuerzo en algunos escenarios corporativos/MDM.
- **Duraciones**: ∞ (indefinido), 15/30/45 min, 1h, 4h, 8h, 12h. Al activarse
  con una duración, se programa un `Timer` que desactiva el modo
  automáticamente.
- **Inicio automático**: usa `SMAppService.mainApp` (API moderna de
  `ServiceManagement`, macOS 13+) para registrar la app como ítem de inicio
  de sesión.

## Permisos

Si activas el respaldo de tecla neutra, macOS pedirá permiso de
**Accesibilidad** la primera vez que se envíe el evento `CGEvent`. Puedes
concederlo en:

**Ajustes del Sistema → Privacidad y seguridad → Accesibilidad**

Si solo usas la assertion de IOKit (comportamiento por defecto), **no se
necesita ningún permiso especial**.
