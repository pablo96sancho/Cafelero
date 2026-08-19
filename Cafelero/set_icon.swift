#!/usr/bin/env swift
import AppKit

let arguments = CommandLine.arguments
guard arguments.count >= 3 else {
    print("Usage: ./set_icon.swift <icon_path> <target_path>")
    exit(1)
}

let iconPath = arguments[1]
let targetPath = arguments[2]

guard let image = NSImage(contentsOfFile: iconPath) else {
    print("Error: Could not load image at \(iconPath)")
    exit(1)
}

let success = NSWorkspace.shared.setIcon(image, forFile: targetPath, options: [])
if success {
    print("✅ Successfully set icon \(iconPath) on \(targetPath)")
} else {
    print("❌ Failed to set icon")
    exit(1)
}
