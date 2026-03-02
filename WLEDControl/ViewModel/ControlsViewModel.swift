//
//  ControlsViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-03.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ControlsViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var error: String?

    let host: String
    private let deviceStore: DeviceStore
    private var cancellables = Set<AnyCancellable>()
    let id = UUID()

    init(host: String, deviceStore: DeviceStore = .shared) {
        self.host = host
        self.deviceStore = deviceStore
        self.device = deviceStore.currentDevice(for: host)

        deviceStore.devicePublisher(for: host)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.device = device
            }
            .store(in: &cancellables)
    }

    func updateBrightness(to value: Double) async {
        do {
            try await deviceStore.updateBrightness(host: host, value: value)
        } catch {
            self.error = "Failed to update brightness: \(error.localizedDescription)"
        }
    }

    func updateEffectSpeed(to value: Double) async {
        do {
            try await deviceStore.updateEffectSpeed(host: host, value: value)
        } catch {
            self.error = "Failed to update effect speed: \(error.localizedDescription)"
        }
    }

    func updateEffectSize(to value: Double) async {
        do {
            try await deviceStore.updateEffectSize(host: host, value: value)
        } catch {
            self.error = "Failed to update effect size: \(error.localizedDescription)"
        }
    }

    func clearError() {
        error = nil
    }
}
