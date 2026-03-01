//
//  DiscoveryViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-01.
//

import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject {
    private let discoveryService: WLEDDiscoveryService
    private var cancellables = Set<AnyCancellable>()
    let id = UUID()

    @Published private(set) var discoveredDevices: Set<DiscoveredDevice> = []
    @Published private(set) var isDiscovering: Bool = false
    @Published private(set) var error: String?

    init(discoveryService: WLEDDiscoveryService = WLEDDiscoveryService()) {
        self.discoveryService = discoveryService
        setupBindings()
    }

    private func setupBindings() {
        // Bind devices
        discoveryService.devicesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.discoveredDevices, on: self)
            .store(in: &cancellables)

        // Bind state
        discoveryService.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .idle:
                    self?.isDiscovering = false
                    self?.error = nil
                case .discovering:
                    self?.isDiscovering = true
                    self?.error = nil
                case .error(let message):
                    self?.isDiscovering = false
                    self?.error = message
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

    deinit {
        stopDiscovery()
        cancellables.removeAll()
    }
}
