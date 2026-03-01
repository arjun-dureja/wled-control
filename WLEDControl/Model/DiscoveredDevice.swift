//
//  DiscoveredDevice.swift
//  WLEDControl
//

import Foundation

struct DiscoveredDevice: Identifiable, Hashable {
    var id: String { host }
    let name: String
    let host: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(host)
    }

    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        lhs.host == rhs.host
    }
}
