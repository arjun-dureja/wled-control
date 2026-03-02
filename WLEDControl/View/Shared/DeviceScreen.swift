//
//  DeviceScreen.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import SwiftUI

struct DeviceScreen<Content: View>: View {
    @EnvironmentObject var navigationService: NavigationService

    let host: String
    private let deviceStore = DeviceStore.shared
    @State private var monitoringScopeID = UUID().uuidString
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(viewModel: HeaderViewModel(host: host))

            content()

            Spacer()
            FooterView()
        }
        .onAppear {
            deviceStore.beginMonitoring(scopeID: monitoringScopeID, hosts: [host])
        }
        .onDisappear {
            deviceStore.endMonitoring(scopeID: monitoringScopeID)
        }
        .onReceive(deviceStore.presencePublisher(for: host)) { presence in
            if presence.status == .offline {
                Task { @MainActor in
                    navigationService.goBackToRoot()
                }
            }
        }
    }
}
