//
//  WLEDDevice.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-16.
//

import Foundation
import AppKit

struct WLEDDevice: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    var ipAddress: String
    var nickname: String
    var isOn: Bool
    var brightness: Double
    var preset: Int?
    var effect: Int
    var effectSpeed: Double
    var effectSize: Double
    var palette: Int
    var colors: WLEDColors

    static func == (lhs: WLEDDevice, rhs: WLEDDevice) -> Bool {
        return lhs.id == rhs.id
    }

    static var defaultDevice: WLEDDevice {
        return WLEDDevice(ipAddress: "", nickname: "", isOn: false, brightness: 0, preset: nil, effect: 0, effectSpeed: 0, effectSize: 0, palette: 0, colors: .init(colorOne: .init(nsColor: .red), colorTwo: .init(nsColor: .red), colorThree: .init(nsColor: .red)))
    }
}

struct WLEDColors: Codable, Hashable {
    var colorOne: WLEDColor
    var colorTwo: WLEDColor
    var colorThree: WLEDColor
}

struct WLEDColor: Codable, Hashable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var nsColor: NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(nsColor: NSColor) {
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
