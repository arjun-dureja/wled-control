//
//  ManualDeviceInfoResponse.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import Foundation

struct ManualDeviceInfoResponse: Decodable {
    let brand: String
    let name: String?
    let mac: String?
}
