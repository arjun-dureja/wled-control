//
//  AddDeviceViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-22.
//

import Foundation
import Combine

@MainActor
class AddDeviceViewModel: ObservableObject {
    private let discoveryService: WLEDDiscoveryService
    private let deviceStore: DeviceStore
    private let monitoringScopeID = UUID().uuidString
    private var monitoredHosts: Set<String> = []
    private var isMonitoringSavedDevices = false
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var discoveredDevices: [DiscoveredDevice] = []
    @Published private(set) var isDiscovering: Bool = false
    @Published var manualIPAddress: String = ""
    @Published private(set) var isValidatingIP: Bool = false
    @Published var error: String?
    @Published private(set) var addedDeviceHost: String?

    let id = UUID()

    init(
        discoveryService: WLEDDiscoveryService = WLEDDiscoveryService(),
        deviceStore: DeviceStore = .shared
    ) {
        self.discoveryService = discoveryService
        self.deviceStore = deviceStore
        setupBindings()
    }

    private func setupBindings() {
        discoveryService.devicesPublisher
            .receive(on: DispatchQueue.main)
            .map { Array($0).sorted { $0.name < $1.name } }
            .assign(to: \.discoveredDevices, on: self)
            .store(in: &cancellables)

        discoveryService.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .idle:
                    self?.isDiscovering = false
                case .discovering:
                    self?.isDiscovering = true
                case .error:
                    self?.isDiscovering = false
                    self?.error = "Failed to discover devices. Please try again."
                }
            }
            .store(in: &cancellables)

        deviceStore.savedDevicesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                guard let self = self else { return }
                self.monitoredHosts = Set(devices.map(\.host))
                if self.isMonitoringSavedDevices {
                    self.deviceStore.beginMonitoring(
                        scopeID: self.monitoringScopeID,
                        hosts: self.monitoredHosts
                    )
                }
            }
            .store(in: &cancellables)
    }

    func startDiscovery() {
        discoveryService.startDiscovery()
    }

    func stopDiscovery() {
        discoveryService.stopDiscovery()
    }

    func startMonitoringSavedDevices() {
        isMonitoringSavedDevices = true
        deviceStore.beginMonitoring(
            scopeID: monitoringScopeID,
            hosts: monitoredHosts
        )
    }

    func stopMonitoringSavedDevices() {
        isMonitoringSavedDevices = false
        deviceStore.endMonitoring(scopeID: monitoringScopeID)
    }

    func isDeviceSaved(_ device: DiscoveredDevice) -> Bool {
        deviceStore.loadSavedDevices().contains { $0.host == device.host }
    }

    func addDevice(_ discoveredDevice: DiscoveredDevice) {
        let saved = SavedDevice(host: discoveredDevice.host, nickname: discoveredDevice.name)
        deviceStore.addDevice(saved)
        addedDeviceHost = saved.host
    }

    func addDeviceManually(ipAddress: String) async {
        isValidatingIP = true
        error = nil
        defer { isValidatingIP = false }

        do {
            let host = try validateManualHost(ipAddress)
            let info = try await fetchDeviceInfo(host: host)
            let savedDevice = savedDevice(from: info, host: host)
            deviceStore.addDevice(savedDevice)
            addedDeviceHost = savedDevice.host
            manualIPAddress = ""
        } catch {
            self.error = userMessage(for: error)
            if let manualError = error as? AddManualDeviceError, case .duplicateDevice = manualError {
                manualIPAddress = ""
            }
        }
    }

    private func validateManualHost(_ ipAddress: String) throws -> String {
        let trimmedHost = ipAddress.trimmingCharacters(in: .whitespaces)
        guard !trimmedHost.isEmpty else { throw AddManualDeviceError.invalidIPAddress }

        guard URL(string: "http://\(trimmedHost)/json/info") != nil else {
            throw AddManualDeviceError.invalidIPAddress
        }

        if deviceStore.loadSavedDevices().contains(where: { $0.host == trimmedHost }) {
            throw AddManualDeviceError.duplicateDevice
        }

        return trimmedHost
    }

    private func fetchDeviceInfo(host: String) async throws -> ManualDeviceInfo {
        guard let url = URL(string: "http://\(host)/json/info") else {
            throw AddManualDeviceError.invalidIPAddress
        }

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        configuration.timeoutIntervalForResource = 3
        let session = URLSession(configuration: configuration)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw AddManualDeviceError.deviceNotFound
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AddManualDeviceError.deviceNotFound
        }

        guard let payload = try? JSONDecoder().decode(ManualDeviceInfoResponse.self, from: data) else {
            throw AddManualDeviceError.invalidResponse
        }

        guard payload.brand == "WLED" else {
            throw AddManualDeviceError.notWLEDDevice
        }

        return ManualDeviceInfo(
            name: payload.name ?? "WLED",
            mac: payload.mac ?? ""
        )
    }

    private func savedDevice(from info: ManualDeviceInfo, host: String) -> SavedDevice {
        let macSuffix = String(info.mac.suffix(6)).lowercased()
        let displayName = (info.name == "WLED" && !macSuffix.isEmpty) ? "wled-\(macSuffix)" : info.name
        return SavedDevice(host: host, nickname: displayName)
    }

    private func userMessage(for error: Error) -> String {
        guard let manualError = error as? AddManualDeviceError else {
            return "Failed to add device"
        }

        switch manualError {
        case .invalidIPAddress:
            return "Invalid IP address"
        case .duplicateDevice:
            return "Device already added"
        case .deviceNotFound:
            return "Device not found"
        case .invalidResponse:
            return "Failed to read device information"
        case .notWLEDDevice:
            return "Not a WLED device"
        }
    }

    func clearError() {
        error = nil
    }
}
