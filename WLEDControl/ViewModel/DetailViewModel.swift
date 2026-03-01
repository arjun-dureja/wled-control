//
//  DetailViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-01.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var isLoading = true

    let service: WLEDService
    private var cancellables = Set<AnyCancellable>()
    private var heartbeatTask: Task<Void, Never>?
    let id = UUID()
    var onNicknameChanged: ((String) -> Void)?
    var onDeviceOffline: (() -> Void)?

    init(service: WLEDService) {
        self.service = service
        self.device = service.device

        service.devicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.device = device
            }
            .store(in: &cancellables)

        service.initialStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func startHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = Task { [weak self] in
            var consecutiveFailures = 0
            while !Task.isCancelled {
                let isOnline = await self?.checkConnection() ?? false
                if isOnline {
                    consecutiveFailures = 0
                } else {
                    consecutiveFailures += 1
                    if consecutiveFailures >= 2 {
                        self?.onDeviceOffline?()
                        return
                    }
                }
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }

    private func checkConnection() async -> Bool {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
        let session = URLSession(configuration: config)

        guard let url = URL(string: "http://\(device.ipAddress)/json/info") else {
            return false
        }

        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            }
            return false
        } catch {
            return false
        }
    }

    func updatePower(to isOn: Bool) async {
        self.device.isOn = isOn

        do {
            let payload = StateUpdatePayload(on: isOn)
            try await service.sendStateUpdate(payload: payload)
        } catch {
            self.device.isOn = !isOn
        }
    }

    func updateNickname(_ nickname: String) {
        device.nickname = nickname
        service.device.nickname = nickname
        service.deviceSubject.send(device)
        onNicknameChanged?(nickname)
    }

    deinit {
        heartbeatTask?.cancel()
    }
}
