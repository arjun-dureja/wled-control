# WLEDControl

<p align="center"><a href="https://apps.apple.com/us/app/wledcontrol/id6759883611"><img src="/images/banner.png"/></a></p>

[![Swift](https://img.shields.io/badge/swift-orange.svg)](https://swift.org)
[![GitHub stars](https://img.shields.io/github/stars/arjun-dureja/WLEDControl.svg)](https://github.com/arjun-dureja/WLEDControl/stargazers)
[![GitHub license](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)](https://developer.apple.com/macos/)

WLEDControl is a macOS menu bar app for controlling [WLED](https://kno.wled.ge/) devices on your local network.

It focuses on fast everyday actions: toggle power, set brightness, pick colors, and apply effects/palettes.

## Features
- Quick access from the macOS menu bar
- Discover WLED devices on your local network or add devices manually
- Power on/off and adjust brightness
- Live presence monitoring (online/offline/connecting)
- Device rename and local persistence
- Controls for power, brightness, effect speed/size
- Color wheel + hex input
- Effects and palette browsing

## Screenshots

<img src="./images/home.png" width="400"/> <img src="./images/actions.png" width="400"/>
<img src="./images/controls.png" width="400"/> <img src="./images/colors.png" width="400"/>

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

## Dependencies

- [Starscream](https://github.com/daltoniam/Starscream)
- [FluidMenuBarExtra](https://github.com/lfroms/fluid-menu-bar-extra)
- [ModernSlider](https://github.com/arjun-dureja/ModernSlider)

## Contributing

Contributions are welcome! Open an issue or submit a pull request.
