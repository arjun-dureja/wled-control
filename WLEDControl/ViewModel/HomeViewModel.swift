//
//  HomeViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-17.
//

import Foundation
import Combine

struct SavedDeviceWithStatus: Identifiable {
    var id: String { device.host }
    let device: SavedDevice
    var status: SavedDevice.ConnectionStatus
    var color: DeviceColor?
}

@MainActor
class HomeViewModel: ObservableObject {
    private let deviceStore: DeviceStore
    private var cancellables = Set<AnyCancellable>()
    private let monitoringScopeID = UUID().uuidString
    private var isMonitoring = false
    private var latestSavedDevices: [SavedDevice] = []
    private var latestPresenceByHost: [String: DevicePresenceState] = [:]

    @Published var savedDevices: [SavedDeviceWithStatus] = []

    init(deviceStore: DeviceStore = .shared) {
        self.deviceStore = deviceStore

        Publishers.CombineLatest(
            deviceStore.savedDevicesPublisher,
            deviceStore.presenceByHostPublisher
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices, presenceByHost in
                guard let self else { return }
                self.latestSavedDevices = devices
                self.latestPresenceByHost = presenceByHost
                self.rebuildSavedDevices()
                if self.isMonitoring {
                    self.deviceStore.beginMonitoring(
                        scopeID: self.monitoringScopeID,
                        hosts: Set(devices.map(\.host))
                    )
                }
            }
            .store(in: &cancellables)

        deviceStore.refreshSavedDevices()
    }

    private func rebuildSavedDevices() {
        let existingByHost = Dictionary(uniqueKeysWithValues: savedDevices.map { ($0.device.host, $0) })

        savedDevices = latestSavedDevices.map { device in
            let presence = latestPresenceByHost[device.host] ?? .connecting

            let status: SavedDevice.ConnectionStatus
            switch presence.status {
            case .connecting:
                status = .connecting
            case .online:
                status = .online
            case .offline:
                status = .offline
            }

            let color = presence.color ?? existingByHost[device.host]?.color ?? device.color1

            if let existing = existingByHost[device.host] {
                return SavedDeviceWithStatus(
                    device: device,
                    status: status,
                    color: color
                )
            }

            return SavedDeviceWithStatus(device: device, status: status, color: color)
        }
    }

    func startMonitoring() {
        isMonitoring = true
        deviceStore.beginMonitoring(
            scopeID: monitoringScopeID,
            hosts: Set(latestSavedDevices.map(\.host))
        )
    }

    func stopMonitoring() {
        isMonitoring = false
        deviceStore.endMonitoring(scopeID: monitoringScopeID)
    }

    func updateNickname(for host: String, nickname: String) {
        deviceStore.renameDevice(host: host, nickname: nickname)
    }

    func deleteDevice(_ host: String) {
        deviceStore.removeDevice(host: host)
    }

    func refreshDevices() {
        deviceStore.refreshSavedDevices()
        if isMonitoring {
            deviceStore.beginMonitoring(
                scopeID: monitoringScopeID,
                hosts: Set(latestSavedDevices.map(\.host))
            )
        }
    }

}
