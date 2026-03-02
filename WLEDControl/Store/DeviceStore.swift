//
//  DeviceStore.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-01.
//

import Foundation
import Combine

struct DevicePresenceState: Equatable {
    enum Status: Equatable {
        case connecting
        case online
        case offline
    }

    var status: Status
    var color: DeviceColor?

    static var connecting: DevicePresenceState {
        DevicePresenceState(status: .connecting, color: nil)
    }
}

final class DeviceStore {
    static let shared = DeviceStore()

    private let storage: DeviceStorageService
    private let savedDevicesSubject: CurrentValueSubject<[SavedDevice], Never>
    private let presenceSubject = CurrentValueSubject<[String: DevicePresenceState], Never>([:])
    private let presenceSession: URLSession
    private var servicesByHost: [String: WLEDService] = [:]
    private var monitoringScopes: [String: Set<String>] = [:]
    private var heartbeatTimer: Timer?

    var savedDevicesPublisher: AnyPublisher<[SavedDevice], Never> {
        savedDevicesSubject.eraseToAnyPublisher()
    }

    var presenceByHostPublisher: AnyPublisher<[String: DevicePresenceState], Never> {
        presenceSubject.eraseToAnyPublisher()
    }

    private init(storage: DeviceStorageService = .shared) {
        self.storage = storage
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.presenceSession = URLSession(configuration: config)
        self.savedDevicesSubject = CurrentValueSubject(storage.loadDevices())
    }

    func loadSavedDevices() -> [SavedDevice] {
        savedDevicesSubject.value
    }

    func refreshSavedDevices() {
        let savedDevices = storage.loadDevices()
        savedDevicesSubject.send(savedDevices)
        let savedHosts = Set(savedDevices.map(\.host))
        pruneServices(to: savedHosts)
        prunePresence(to: savedHosts)
        reconcileMonitoringHosts()
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
        resolveService(for: host)
    }

    func beginMonitoring(scopeID: String, hosts: Set<String>) {
        monitoringScopes[scopeID] = hosts
        reconcileMonitoringHosts()
    }

    func endMonitoring(scopeID: String) {
        monitoringScopes.removeValue(forKey: scopeID)
        reconcileMonitoringHosts()
    }

    func presencePublisher(for host: String) -> AnyPublisher<DevicePresenceState, Never> {
        presenceByHostPublisher
            .map { $0[host] ?? .connecting }
            .removeDuplicates()
            .eraseToAnyPublisher()
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
        device.nickname = nicknameForHost(host)
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

    private func prunePresence(to validHosts: Set<String>) {
        var current = presenceSubject.value
        let staleHosts = current.keys.filter { !validHosts.contains($0) }
        staleHosts.forEach { current.removeValue(forKey: $0) }
        if current != presenceSubject.value {
            presenceSubject.send(current)
        }
    }

    private func reconcileMonitoringHosts() {
        let monitoredHosts = currentMonitoredHosts()

        var presence = presenceSubject.value
        for host in monitoredHosts where presence[host] == nil {
            presence[host] = .connecting
        }
        if presence != presenceSubject.value {
            presenceSubject.send(presence)
        }

        guard !monitoredHosts.isEmpty else {
            stopHeartbeat()
            return
        }

        if heartbeatTimer == nil {
            pollHosts(monitoredHosts)
            heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.pollHosts(self.currentMonitoredHosts())
            }
        } else {
            pollHosts(monitoredHosts)
        }
    }

    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func pollHosts(_ hosts: Set<String>) {
        for host in hosts {
            checkHostPresence(host)
        }
    }

    private func currentMonitoredHosts() -> Set<String> {
        let savedHosts = Set(savedDevicesSubject.value.map(\.host))
        return Set(monitoringScopes.values.flatMap { $0 }).intersection(savedHosts)
    }

    private func checkHostPresence(_ host: String) {
        guard let url = URL(string: "http://\(host)/json/state") else {
            updatePresence(host: host, status: .offline, color: nil)
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let task = presenceSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let isOnline = (statusCode == 200 && error == nil)
            let color: DeviceColor? = {
                guard isOnline, let data,
                      let ledState = try? JSONDecoder().decode(LEDState.self, from: data) else { return nil }
                let color1 = ledState.seg.first?.col.first ?? [0, 0, 0]
                return DeviceColor(
                    red: CGFloat(color1[0]) / 255.0,
                    green: CGFloat(color1[1]) / 255.0,
                    blue: CGFloat(color1[2]) / 255.0
                )
            }()

            DispatchQueue.main.async {
                self.updatePresence(host: host, status: isOnline ? .online : .offline, color: color)
            }
        }
        task.resume()
    }

    private func updatePresence(host: String, status: DevicePresenceState.Status, color: DeviceColor?) {
        var current = presenceSubject.value
        let newState = DevicePresenceState(status: status, color: color)
        guard current[host] != newState else { return }
        current[host] = newState
        presenceSubject.send(current)
    }

    private func sendStateUpdate(host: String, payload: StateUpdatePayload) async throws {
        try await service(for: host).sendStateUpdate(payload: payload)
    }

    private func resolveService(for host: String) -> WLEDService {
        if let existingService = servicesByHost[host] {
            return existingService
        }

        let service = WLEDService(ipAddr: host)
        servicesByHost[host] = service
        return service
    }

    private func nicknameForHost(_ host: String) -> String {
        savedDevicesSubject.value.first(where: { $0.host == host })?.nickname ?? "WLED Device"
    }
}
