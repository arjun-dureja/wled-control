//
//  AddDeviceRow.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-22.
//

import SwiftUI

struct AddDeviceRow: View {
    let device: DiscoveredDevice
    let isSaved: Bool
    let onAdd: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        DeviceRow(
            icon: {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Accent.wledDefault)
            },
            title: device.name,
            subtitle: device.host
        ) {
            if isSaved {
                Text("Added")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(colorScheme == .dark ? Theme.Icon.dark : Theme.Icon.light)
                    .clipShape(.rect(cornerRadius: 6))
            } else {
                Button {
                    onAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
