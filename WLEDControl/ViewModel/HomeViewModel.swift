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

class HomeViewModel: ObservableObject {
    private let deviceStorage = DeviceStorage.shared
    private var cancellables = Set<AnyCancellable>()
    private var heartbeatTimer: Timer?

    @Published var savedDevices: [SavedDeviceWithStatus] = []

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
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkSavedDevicesConnection()
        }
    }

    func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    func checkSavedDevicesConnection() {
        for index in savedDevices.indices {
            checkDeviceConnection(at: index)
        }
    }

    private func checkDeviceConnection(at index: Int) {
        guard index < savedDevices.count else { return }
        let host = savedDevices[index].device.host

        guard let url = URL(string: "http://\(host)/json/state") else {
            updateDeviceStatus(host: host, status: .offline, color: nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, _ in
            guard let self = self else { return }
            
            let isOnline = (response as? HTTPURLResponse)?.statusCode == 200
            let color: DeviceColor? = {
                guard isOnline, let data = data,
                      let ledState = try? JSONDecoder().decode(LEDState.self, from: data) else { return nil }
                let color1 = ledState.seg.first?.col.first ?? [0, 0, 0]
                return DeviceColor(
                    red: CGFloat(color1[0]) / 255.0,
                    green: CGFloat(color1[1]) / 255.0,
                    blue: CGFloat(color1[2]) / 255.0
                )
            }()
            
            DispatchQueue.main.async {
                self.updateDeviceStatus(host: host, status: isOnline ? .online : .offline, color: color)
            }
        }
        task.resume()
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
        stopHeartbeat()
        cancellables.removeAll()
    }
}
