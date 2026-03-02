//
//  DeviceStorageService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-22.
//

import Foundation

/// Persists user-managed device metadata (saved devices and nicknames) in user defaults.
class DeviceStorageService {
    static let shared = DeviceStorageService()
    private let userDefaultsKey = "savedDevices"

    private init() {}

    func loadDevices() -> [SavedDevice] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([SavedDevice].self, from: data)) ?? []
    }

    func saveDevices(_ devices: [SavedDevice]) {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    func addDevice(_ device: SavedDevice) {
        var devices = loadDevices()
        if !devices.contains(where: { $0.host == device.host }) {
            devices.append(device)
            saveDevices(devices)
        }
    }

    func updateNickname(for host: String, nickname: String) {
        var devices = loadDevices()
        if let index = devices.firstIndex(where: { $0.host == host }) {
            devices[index].nickname = nickname
            saveDevices(devices)
        }
    }

    func removeDevice(host: String) {
        var devices = loadDevices()
        devices.removeAll { $0.host == host }
        saveDevices(devices)
    }
}
