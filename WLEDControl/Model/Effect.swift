//
//  Effect.swift
//  WLEDControl
//

import Foundation

struct Effect: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let index: Int
}
