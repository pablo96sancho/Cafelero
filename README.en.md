<div align="center">

<img src="docs/Cafelero%20ICONS/Cafelero%20ICON-iOS-Default-1024@1x.png" width="128" alt="Cafelero icon" />

# Cafelero

**Keep your Mac awake with a single click.**

[![Download for macOS](https://img.shields.io/badge/Download_for_macOS-0071E3?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/pablo96sancho/Cafelero/releases/latest/download/Cafelero-Installer.dmg)

![Version](https://img.shields.io/github/v/release/pablo96sancho/Cafelero?style=flat-square&label=version&color=000000)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-000000?style=flat-square&logo=apple&logoColor=white)
![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-M1%2B-000000?style=flat-square)
![MIT License](https://img.shields.io/badge/license-MIT-000000?style=flat-square)

[🇪🇸 Versión en español](./README.md)

</div>

<br />

<p align="center">
  <img src="screenshot.png" width="320" alt="Cafelero's menu bar menu, with the toggle and the durations" />
</p>

Cafelero is a menu bar app that stops your Mac from sleeping or starting the screen saver
while you work, present or download files. The interface is in Spanish.

## Features

- ☕️ Turn it on and off with a toggle in the menu bar.
- ⏱️ Ready-made durations: 15, 30 and 45 min, 1, 4, 8 and 12 hours, or **∞** with no limit.
- 💻 Native and lightweight: written in Swift with SwiftUI, no dependencies.
- 🔒 No special permissions in normal mode.

## Installation

1. [Download the installer](https://github.com/pablo96sancho/Cafelero/releases/latest/download/Cafelero-Installer.dmg).
2. Open it and drag **Cafelero.app** to **Applications**.
3. Launch it. It will appear in the menu bar.

### First launch

The app isn't signed with an Apple Developer account, so macOS blocks it the first time.
To open it:

1. Try to open Cafelero and close the warning (don't move it to the Trash).
2. Go to **System Settings → Privacy & Security**.
3. Under **Security**, click **Open Anyway** next to the message about Cafelero.
4. Confirm with your password or Touch ID. You only need to do this once.

<details>
<summary>Alternative using Terminal</summary>

```bash
xattr -dr com.apple.quarantine /Applications/Cafelero.app
```

</details>

### Permissions

Cafelero keeps your Mac awake with an IOKit *power assertion*, which needs no permission.
Only if you turn on the **neutral keyboard fallback** option will macOS ask for
**Accessibility** permission the first time: *System Settings → Privacy & Security →
Accessibility*.

## Development

Requirements: macOS 13 or later, Xcode 15+ (or the Command Line Tools) and Swift 5.9+.

```bash
cd Cafelero
./build_and_run.sh   # builds and opens the app
./create_dmg.sh      # creates Cafelero-Installer.dmg
```

Every GitHub Release publishes the DMG automatically with GitHub Actions.

## License

[MIT](LICENSE) © Pablo Sancho
