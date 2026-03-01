//
//  DiscoveryView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-01.
//

import SwiftUI

struct DiscoveryView: View {
    @ObservedObject var viewModel: DiscoveryViewModel

    var body: some View {
        VStack {
            List(Array(viewModel.discoveredDevices)) { device in
                Text(device.name)
            }
            .overlay(Group {
                if viewModel.isDiscovering {
                    ProgressView()
                }
            })
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .onAppear {
            viewModel.startDiscovery()
        }
        .onDisappear {
            viewModel.stopDiscovery()
        }
    }
}

#Preview {
    DiscoveryView(viewModel: DiscoveryViewModel())
}
