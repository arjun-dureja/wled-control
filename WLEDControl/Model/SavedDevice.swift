//
//  SavedDevice.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-22.
//

import Foundation
import AppKit

struct SavedDevice: Codable, Identifiable, Hashable, Equatable {
    var id: String { host }
    let host: String
    var nickname: String
    var color1: DeviceColor? = nil

    enum ConnectionStatus {
        case connecting
        case online
        case offline
    }
}

struct DeviceColor: Codable, Hashable {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    var nsColor: NSColor {
        NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(nsColor: NSColor) {
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = 1.0
    }
}
