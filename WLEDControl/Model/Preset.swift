//
//  Preset.swift
//  WLEDControl
//

import Foundation

struct Preset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let index: Int
}
