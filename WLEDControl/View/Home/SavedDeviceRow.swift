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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                ZStack {
                    Image(systemName: savedDevice.status == .offline ? "lightbulb" : "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                        .frame(width: 36, height: 36)

                    if savedDevice.status == .connecting {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(savedDevice.device.nickname)
                        .font(.headline)
                        .foregroundStyle(savedDevice.status == .offline ? .secondary : .primary)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if savedDevice.status == .online {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .cardBackground()
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

    private var statusColor: Color {
        switch savedDevice.status {
        case .connecting:
            return Theme.Status.connecting
        case .online:
            return Theme.Status.online
        case .offline:
            return Theme.Status.offline
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
