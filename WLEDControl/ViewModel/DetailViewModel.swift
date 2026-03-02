//
//  DetailViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-01.
//

import Foundation
import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
    let host: String
    let id = UUID()

    init(host: String) {
        self.host = host
    }
}
