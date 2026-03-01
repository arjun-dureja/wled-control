//
//  DeviceScreen.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import SwiftUI

struct DeviceScreen<Content: View>: View {
    let service: WLEDService
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(viewModel: HeaderViewModel(service: service))
            
            content()

            Spacer()
            FooterView()
        }
    }
}
