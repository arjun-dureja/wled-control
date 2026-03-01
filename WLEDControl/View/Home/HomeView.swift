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

            FooterView()
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
                .frame(width: 30, height: 28)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)

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

}

#Preview {
    HomeView(viewModel: HomeViewModel())
        .frame(width: 330, height: 440)
}
