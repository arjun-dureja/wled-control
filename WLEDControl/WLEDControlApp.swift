//
//  WLEDControlApp.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2023-11-13.
//

import SwiftUI

@main
struct WLEDControlApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        // EmptyView needed to satisfy the compiler.
        // The actual scene is defined in the AppDelegate.
        Settings {
            EmptyView()
        }
    }
}
