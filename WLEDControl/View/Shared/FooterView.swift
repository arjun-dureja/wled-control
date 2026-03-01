//
//  FooterView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import SwiftUI
import AppKit

struct FooterView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("WLEDControl v\(appVersion)")
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .opacity(0.8)
            }
            .padding()
        }
    }
}
