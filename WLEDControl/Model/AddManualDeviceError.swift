//
//  AddManualDeviceError.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-01.
//

import Foundation

enum AddManualDeviceError: Error {
    case invalidIPAddress
    case duplicateDevice
    case deviceNotFound
    case invalidResponse
    case notWLEDDevice
}
