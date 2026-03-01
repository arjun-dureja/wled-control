//
//  DetailViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-01.
//

import Foundation
import Combine
import SwiftUI

class DetailViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var isLoading = true

    let service: WLEDService
    private var cancellables = Set<AnyCancellable>()
    private var heartbeatTimer: Timer?
    private var consecutiveFailures = 0
    let id = UUID()
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
        heartbeatTimer?.invalidate()
        consecutiveFailures = 0
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkConnection()
        }
    }

    func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func checkConnection() {
        guard let url = URL(string: "http://\(device.ipAddress)/json/info") else {
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { [weak self] _, response, _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                let isOnline = (response as? HTTPURLResponse)?.statusCode == 200
                if isOnline {
                    self.consecutiveFailures = 0
                } else {
                    self.consecutiveFailures += 1
                    if self.consecutiveFailures >= 2 {
                        self.onDeviceOffline?()
                        self.stopHeartbeat()
                    }
                }
            }
        }
        task.resume()
    }

    deinit {
        stopHeartbeat()
    }
}
