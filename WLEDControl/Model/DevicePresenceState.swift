//
//  DevicePresenceState.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import Foundation

struct DevicePresenceState: Equatable {
    enum Status: Equatable {
        case connecting
        case online
        case offline
    }

    var status: Status
    var color: DeviceColor?

    static var connecting: DevicePresenceState {
        DevicePresenceState(status: .connecting, color: nil)
    }
}
