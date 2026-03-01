//
//  AppDelegate.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-16.
//

import AppKit
import FluidMenuBarExtra
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarExtra: FluidMenuBarExtra?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.menuBarExtra = FluidMenuBarExtra(title: "WLEDControl", systemImage: "lightbulb") {
            ContentView()
        }
    }
}
