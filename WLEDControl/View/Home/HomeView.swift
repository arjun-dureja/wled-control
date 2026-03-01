//
//  HomeView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-01.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationService: NavigationService
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    myDevicesSection
                }
                .padding()
            }

            Divider()

            footerView
        }
        .onAppear {
            viewModel.refreshDevices()
            viewModel.startHeartbeat()
        }
        .onDisappear {
            viewModel.stopHeartbeat()
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 28, height: 28)

                Text("WLEDControl")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    navigationService.navigate(to: .addDevice(addDeviceViewModel: AddDeviceViewModel()))
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 40)
            }
            .padding()

            Divider()
        }
    }

    private var myDevicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Devices")
                .font(.headline)
                .foregroundStyle(.secondary)

            if viewModel.savedDevices.isEmpty {
                Text("No devices saved yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.savedDevices) { savedDevice in
                    SavedDeviceRow(
                        savedDevice: savedDevice,
                        onTap: {
                            guard savedDevice.status == .online else { return }
                            let service = viewModel.createService(for: savedDevice.device)
                            let detailVM = DetailViewModel(service: service)
                            detailVM.onNicknameChanged = { nickname in
                                viewModel.updateNickname(for: savedDevice.device.host, nickname: nickname)
                            }
                            detailVM.onDeviceOffline = {
                                navigationService.goBackToRoot()
                            }
                            navigationService.navigate(
                                to: .detail(detailViewModel: detailVM)
                            )
                        },
                        onDelete: {
                            viewModel.deleteDevice(savedDevice.device.host)
                        }
                    )
                }
            }
        }
    }

    private var footerView: some View {
        HStack {
            Text("WLEDControl")
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

struct SavedDeviceRow: View {
    let savedDevice: SavedDeviceWithStatus
    let onTap: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
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

#Preview {
    HomeView(viewModel: HomeViewModel())
        .frame(width: 330, height: 440)
}
