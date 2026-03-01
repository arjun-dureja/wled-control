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
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18))
                .foregroundColor(Theme.Accent.wledDefault)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(device.host)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

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
        .padding(12)
        .cardBackground()
    }
}
