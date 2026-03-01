//
//  View+Extensions.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import SwiftUI
import AppKit

extension View {
    func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
