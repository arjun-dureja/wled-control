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

    func addDeviceManually(ipAddress: String) {
        isValidatingIP = true
        error = nil

        let trimmedIP = ipAddress.trimmingCharacters(in: .whitespaces)

        if deviceStore.loadSavedDevices().contains(where: { $0.host == trimmedIP }) {
            error = "Device already added"
            manualIPAddress = ""
            isValidatingIP = false
            return
        }

        guard let url = URL(string: "http://\(trimmedIP)/json/info") else {
            error = "Invalid IP address"
            isValidatingIP = false
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 3
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { [weak self] data, response, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    self.error = "Device not found"
                    self.isValidatingIP = false
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let brand = json["brand"] as? String,
                   brand == "WLED" {
                    let name = json["name"] as? String ?? "WLED"
                    let mac = json["mac"] as? String ?? ""
                    let macSuffix = String(mac.suffix(6)).lowercased()
                    let displayName = (name == "WLED" && !macSuffix.isEmpty) ? "wled-\(macSuffix)" : name
                    let saved = SavedDevice(host: trimmedIP, nickname: displayName)
                    self.deviceStore.addDevice(saved)
                    self.addedDeviceHost = saved.host
                    self.manualIPAddress = ""
                } else {
                    self.error = "Not a WLED device"
                }

                self.isValidatingIP = false
            }
        }
        task.resume()
    }

    func clearError() {
        error = nil
    }

}
