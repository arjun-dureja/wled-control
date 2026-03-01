//
//  AddDeviceView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-22.
//

import SwiftUI

struct AddDeviceView: View {
    @EnvironmentObject var navigationService: NavigationService
    @StateObject var viewModel: AddDeviceViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    scanningSection

                    manualAddSection
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startDiscovery()
        }
        .onDisappear {
            viewModel.stopDiscovery()
        }
        .onChange(of: viewModel.addedDeviceHost) { _, newValue in
            if newValue != nil {
                dismiss()
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .frame(width: 30, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading) {
                    Text("Add Device")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

            Divider()
        }
    }

    private var scanningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nearby Devices")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    if viewModel.isDiscovering {
                        viewModel.stopDiscovery()
                    } else {
                        viewModel.startDiscovery()
                    }
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.isDiscovering {
                            ProgressView()
                                .controlSize(.small)
                            Text("Stop")
                        } else {
                            Image(systemName: "arrow.clockwise")
                            Text("Scan")
                        }
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
            }

            if viewModel.discoveredDevices.isEmpty {
                Text(viewModel.isDiscovering ? "Scanning for devices..." : "No devices found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.discoveredDevices) { device in
                    AddDeviceRow(
                        device: device,
                        isSaved: viewModel.isDeviceSaved(device),
                        onAdd: {
                            viewModel.addDevice(device)
                        }
                    )
                }
            }
        }
    }

    private var manualAddSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Manual")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    TextField("Enter IP address", text: $viewModel.manualIPAddress)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(colorScheme == .dark ? Theme.TextField.dark : Theme.TextField.light)
                        .clipShape(.rect(cornerRadius: 6))
                        .onSubmit {
                            guard !viewModel.manualIPAddress.isEmpty && !viewModel.isValidatingIP else { return }
                            Task {
                                await viewModel.addDeviceManually(ipAddress: viewModel.manualIPAddress)
                            }
                        }

                    Button {
                        Task {
                            await viewModel.addDeviceManually(ipAddress: viewModel.manualIPAddress)
                        }
                    } label: {
                        if viewModel.isValidatingIP {
                            ProgressView()
                                .controlSize(.small)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                    .background(colorScheme == .dark ? Theme.TextField.dark : Theme.TextField.light)
                    .clipShape(.rect(cornerRadius: 6))
                    .disabled(viewModel.manualIPAddress.isEmpty || viewModel.isValidatingIP)
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(12)
            .cardBackground()
        }
    }
}

#Preview {
    AddDeviceView(viewModel: AddDeviceViewModel())
        .frame(width: 330, height: 440)
}
