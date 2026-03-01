//
//  SavedDeviceRow.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-01.
//

import SwiftUI

struct SavedDeviceRow: View {
    let savedDevice: SavedDeviceWithStatus
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            DeviceRow(
                icon: {
                    ZStack {
                        Image(systemName: savedDevice.status == .offline ? "lightbulb" : "lightbulb.fill")
                            .font(.system(size: 18))
                            .foregroundColor(iconColor)

                        if savedDevice.status == .connecting {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                },
                title: savedDevice.device.nickname,
                subtitle: statusText,
                titleColor: savedDevice.status == .offline ? .secondary : .primary
            ) {
                if savedDevice.status == .online {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(savedDevice.status != .online)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Device", systemImage: "trash")
            }
        }
    }

    private var iconColor: Color {
        if savedDevice.status == .offline {
            return .gray.opacity(0.5)
        }
        if let color = savedDevice.color {
            return Color(nsColor: color.nsColor)
        }
        return Theme.Accent.wledDefault
    }

    private var statusText: String {
        switch savedDevice.status {
        case .connecting:
            return "Connecting..."
        case .online:
            return savedDevice.device.host
        case .offline:
            return "Offline"
        }
    }
}
