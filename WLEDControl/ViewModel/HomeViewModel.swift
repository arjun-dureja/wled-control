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
    private let deviceStorage = DeviceStorage.shared
    private var cancellables = Set<AnyCancellable>()
    private var heartbeatTask: Task<Void, Never>?

    @Published private(set) var savedDevices: [SavedDeviceWithStatus] = []

    static let devicesDidChange = Notification.Name("devicesDidChange")

    init() {
        loadSavedDevices()
        
        NotificationCenter.default.publisher(for: Self.devicesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadSavedDevices()
            }
            .store(in: &cancellables)
    }

    private func loadSavedDevices() {
        let devices = deviceStorage.loadDevices()
        savedDevices = devices.map { SavedDeviceWithStatus(device: $0, status: .connecting, color: $0.color1) }
        checkSavedDevicesConnection()
    }

    func startHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.checkSavedDevicesConnection()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }

    func checkSavedDevicesConnection() {
        for index in savedDevices.indices {
            checkDeviceConnection(at: index)
        }
    }

    private func checkDeviceConnection(at index: Int) {
        guard index < savedDevices.count else { return }
        let host = savedDevices[index].device.host

        Task { [weak self] in
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 3
            config.timeoutIntervalForResource = 3
            let session = URLSession(configuration: config)

            guard let url = URL(string: "http://\(host)/json/state") else {
                self?.updateDeviceStatus(host: host, status: .offline, color: nil)
                return
            }

            do {
                let (data, response) = try await session.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // WLED /json/state returns LEDState directly, not wrapped
                    if let ledState = try? JSONDecoder().decode(LEDState.self, from: data) {
                        let color1 = ledState.seg.first?.col.first ?? [0, 0, 0]
                        let deviceColor = DeviceColor(
                            red: CGFloat(color1[0]) / 255.0,
                            green: CGFloat(color1[1]) / 255.0,
                            blue: CGFloat(color1[2]) / 255.0
                        )
                        self?.updateDeviceStatus(host: host, status: .online, color: deviceColor)
                    } else {
                        self?.updateDeviceStatus(host: host, status: .online, color: nil)
                    }
                } else {
                    self?.updateDeviceStatus(host: host, status: .offline, color: nil)
                }
            } catch {
                self?.updateDeviceStatus(host: host, status: .offline, color: nil)
            }
        }
    }

    private func updateDeviceStatus(host: String, status: SavedDevice.ConnectionStatus, color: DeviceColor?) {
        if let index = savedDevices.firstIndex(where: { $0.device.host == host }) {
            savedDevices[index].status = status
            savedDevices[index].color = color
        }
    }

    func createService(for savedDevice: SavedDevice) -> WLEDService {
        WLEDService(ipAddr: savedDevice.host, name: savedDevice.nickname)
    }

    func updateNickname(for host: String, nickname: String) {
        deviceStorage.updateNickname(for: host, nickname: nickname)
        if let index = savedDevices.firstIndex(where: { $0.device.host == host }) {
            savedDevices[index] = SavedDeviceWithStatus(
                device: SavedDevice(host: host, nickname: nickname),
                status: savedDevices[index].status,
                color: savedDevices[index].color
            )
        }
    }

    func deleteDevice(_ host: String) {
        deviceStorage.removeDevice(host: host)
        savedDevices.removeAll { $0.device.host == host }
    }

    func refreshDevices() {
        loadSavedDevices()
    }

    deinit {
        heartbeatTask?.cancel()
        cancellables.removeAll()
    }
}
