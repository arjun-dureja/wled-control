//
//  DeviceStore.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-01.
//

import Foundation
import Combine

/// Central source of truth for device state, coordinating persistence, network sessions, and presence updates.
final class DeviceStore {
    static let shared = DeviceStore()

    private let storage: DeviceStorageService
    private let presenceService: PresenceService
    private let savedDevicesSubject: CurrentValueSubject<[SavedDevice], Never>
    private var servicesByHost: [String: WLEDService] = [:]

    var savedDevicesPublisher: AnyPublisher<[SavedDevice], Never> {
        savedDevicesSubject.eraseToAnyPublisher()
    }

    var presenceByHostPublisher: AnyPublisher<[String: DevicePresenceState], Never> {
        presenceService.presenceByHostPublisher
    }

    private init(storage: DeviceStorageService = .shared, presenceService: PresenceService = PresenceService()) {
        self.storage = storage
        self.presenceService = presenceService
        self.savedDevicesSubject = CurrentValueSubject(storage.loadDevices())
        self.presenceService.setValidHosts(Set(savedDevicesSubject.value.map(\.host)))
    }

    func loadSavedDevices() -> [SavedDevice] {
        savedDevicesSubject.value
    }

    func refreshSavedDevices() {
        let savedDevices = storage.loadDevices()
        savedDevicesSubject.send(savedDevices)
        let savedHosts = Set(savedDevices.map(\.host))
        pruneServices(to: savedHosts)
        presenceService.setValidHosts(savedHosts)
    }

    func addDevice(_ device: SavedDevice) {
        storage.addDevice(device)
        refreshSavedDevices()
    }

    func removeDevice(host: String) {
        storage.removeDevice(host: host)
        servicesByHost[host]?.disconnect()
        servicesByHost.removeValue(forKey: host)
        refreshSavedDevices()
    }

    func renameDevice(host: String, nickname: String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        storage.updateNickname(for: host, nickname: trimmed)
        refreshSavedDevices()
    }

    func service(for host: String) -> WLEDService {
        if let existingService = servicesByHost[host] {
            return existingService
        }

        let service = WLEDService(ipAddr: host)
        servicesByHost[host] = service
        return service
    }

    func beginMonitoring(scopeID: String, hosts: Set<String>) {
        presenceService.beginMonitoring(scopeID: scopeID, hosts: hosts)
    }

    func endMonitoring(scopeID: String) {
        presenceService.endMonitoring(scopeID: scopeID)
    }

    func presencePublisher(for host: String) -> AnyPublisher<DevicePresenceState, Never> {
        presenceService.presencePublisher(for: host)
    }

    func devicePublisher(for host: String) -> AnyPublisher<WLEDDevice, Never> {
        let service = service(for: host)
        let nicknamePublisher = savedDevicesPublisher
            .map { devices in
                devices.first(where: { $0.host == host })?.nickname ?? "WLED Device"
            }
            .removeDuplicates()

        return service.devicePublisher
            .prepend(service.device)
            .combineLatest(nicknamePublisher)
            .map { device, nickname in
                var reconciled = device
                reconciled.nickname = nickname
                return reconciled
            }
            .eraseToAnyPublisher()
    }

    func currentDevice(for host: String) -> WLEDDevice {
        var device = service(for: host).device
        device.nickname = savedDevicesSubject.value.first(where: { $0.host == host })?.nickname ?? "WLED Device"
        return device
    }

    func getEffects(host: String) async throws -> [Effect] {
        try await service(for: host).getEffects()
    }

    func getPalettes(host: String) async throws -> [Palette] {
        try await service(for: host).getPalettes()
    }

    func updatePower(host: String, isOn: Bool) async throws {
        try await sendStateUpdate(host: host, payload: StateUpdatePayload(on: isOn))
    }

    func updateBrightness(host: String, value: Double) async throws {
        try await sendStateUpdate(host: host, payload: StateUpdatePayload(bri: Int(value)))
    }

    func updateEffectSpeed(host: String, value: Double) async throws {
        try await sendStateUpdate(
            host: host,
            payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(sx: Int(value))])
        )
    }

    func updateEffectSize(host: String, value: Double) async throws {
        try await sendStateUpdate(
            host: host,
            payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(ix: Int(value))])
        )
    }

    func updateColor(host: String, index: Int, color: [Int]) async throws {
        var segments = [[Int]](repeating: [], count: 3)
        segments[index] = color
        try await sendStateUpdate(
            host: host,
            payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(col: segments)])
        )
    }

    func updateEffect(host: String, index: Int) async throws {
        try await sendStateUpdate(
            host: host,
            payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(fx: index)])
        )
    }

    func updatePalette(host: String, index: Int) async throws {
        try await sendStateUpdate(
            host: host,
            payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(pal: index)])
        )
    }

    private func pruneServices(to validHosts: Set<String>) {
        let staleHosts = servicesByHost.keys.filter { !validHosts.contains($0) }
        staleHosts.forEach { host in
            servicesByHost[host]?.disconnect()
            servicesByHost.removeValue(forKey: host)
        }
    }

    private func sendStateUpdate(host: String, payload: StateUpdatePayload) async throws {
        try await service(for: host).sendStateUpdate(payload: payload)
    }
}
