//
//  SavedDeviceWithStatus.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import Foundation

struct SavedDeviceWithStatus: Identifiable {
    var id: String { device.host }
    let device: SavedDevice
    var status: SavedDevice.ConnectionStatus
    var color: DeviceColor?
}
