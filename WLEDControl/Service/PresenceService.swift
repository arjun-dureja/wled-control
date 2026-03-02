//
//  PresenceService.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-01.
//

import Foundation
import Combine
import CoreGraphics

/// Monitors device reachability and publishes per-host presence (connecting, online, offline).
final class PresenceService {
    private let presenceSubject = CurrentValueSubject<[String: DevicePresenceState], Never>([:])
    private let presenceSession: URLSession
    private var monitoringScopes: [String: Set<String>] = [:]
    private var validHosts: Set<String> = []
    private var heartbeatTimer: Timer?

    var presenceByHostPublisher: AnyPublisher<[String: DevicePresenceState], Never> {
        presenceSubject.eraseToAnyPublisher()
    }

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.presenceSession = URLSession(configuration: config)
    }

    func setValidHosts(_ hosts: Set<String>) {
        validHosts = hosts
        prunePresence(to: hosts)
        reconcileMonitoringHosts()
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
                guard let self else { return }
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
        Set(monitoringScopes.values.flatMap { $0 }).intersection(validHosts)
    }

    private func checkHostPresence(_ host: String) {
        guard let url = URL(string: "http://\(host)/json/state") else {
            updatePresence(host: host, status: .offline, color: nil)
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let task = presenceSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

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
}
