# WLEDControl

[![Swift](https://img.shields.io/badge/swift-orange.svg)](https://swift.org)
[![GitHub stars](https://img.shields.io/github/stars/arjun-dureja/WLEDControl.svg)](https://github.com/arjun-dureja/WLEDControl/stargazers)
[![GitHub license](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)](https://developer.apple.com/macos/)

WLEDControl is a macOS menu bar app for controlling [WLED](https://kno.wled.ge/) devices on your local network.

It focuses on fast everyday actions: toggle power, set brightness, pick colors, and apply effects/palettes.

## Features

- Menu bar-first workflow
- Bonjour discovery for nearby WLED devices
- Manual add by IP address
- Live presence monitoring (online/offline/connecting)
- Device rename and local persistence
- Realtime state updates via WebSocket
- Controls for power, brightness, effect speed/size
- Color wheel + hex input
- Effects and palette browsing

## Screenshots

<!-- Replace these placeholders with your final screenshot paths -->

![Home](./screenshots/home.png)
![Add Device](./screenshots/add-device.png)
![Controls](./screenshots/controls.png)
![Colors](./screenshots/colors.png)
![Effects](./screenshots/effects.png)
![Palettes](./screenshots/palettes.png)

## Project Structure

```text
WLEDControl/
  Model/
  Service/
  Store/
  View/
  ViewModel/
  Theme/
  Extensions/
```

## Requirements

- macOS 14.0+
- Xcode 17+

## Build and Run

Open in Xcode and run the `WLEDControl` scheme, or build from terminal:

```bash
xcodebuild -project WLEDControl.xcodeproj -scheme WLEDControl -configuration Debug build
```
