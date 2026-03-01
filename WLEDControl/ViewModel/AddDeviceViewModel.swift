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
    private let deviceStorage = DeviceStorage.shared
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var discoveredDevices: [DiscoveredDevice] = []
    @Published private(set) var isDiscovering: Bool = false
    @Published var manualIPAddress: String = ""
    @Published private(set) var isValidatingIP: Bool = false
    @Published var error: String?
    @Published private(set) var addedDeviceHost: String?
    
    let id = UUID()

    init(discoveryService: WLEDDiscoveryService = WLEDDiscoveryService()) {
        self.discoveryService = discoveryService
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

    func isDeviceSaved(_ device: DiscoveredDevice) -> Bool {
        deviceStorage.loadDevices().contains { $0.host == device.host }
    }

    func addDevice(_ discoveredDevice: DiscoveredDevice) {
        let saved = SavedDevice(host: discoveredDevice.host, nickname: discoveredDevice.name)
        deviceStorage.addDevice(saved)
        addedDeviceHost = saved.host
        NotificationCenter.default.post(name: HomeViewModel.devicesDidChange, object: nil)
    }

    func addDeviceManually(ipAddress: String) async {
        isValidatingIP = true
        error = nil

        let trimmedIP = ipAddress.trimmingCharacters(in: .whitespaces)

        if deviceStorage.loadDevices().contains(where: { $0.host == trimmedIP }) {
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

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                error = "Device not found"
                isValidatingIP = false
                return
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let brand = json["brand"] as? String,
               brand == "WLED" {
                let name = json["name"] as? String ?? "WLED"
                let mac = json["mac"] as? String ?? ""
                let macSuffix = String(mac.suffix(6)).lowercased()
                let displayName = (name == "WLED" && !macSuffix.isEmpty) ? "wled-\(macSuffix)" : name
                let saved = SavedDevice(host: trimmedIP, nickname: displayName)
                deviceStorage.addDevice(saved)
                addedDeviceHost = saved.host
                manualIPAddress = ""
                NotificationCenter.default.post(name: HomeViewModel.devicesDidChange, object: nil)
            } else {
                error = "Not a WLED device"
            }
        } catch {
            self.error = "Could not connect"
        }

        isValidatingIP = false
    }

    deinit {
        discoveryService.stopDiscovery()
        cancellables.removeAll()
    }
}
