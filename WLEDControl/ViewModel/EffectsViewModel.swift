//
//  EffectsViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-05.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class EffectsViewModel: ObservableObject {
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

    func getEffects() async -> [Effect] {
        do {
            return try await deviceStore.getEffects(host: host)
        } catch {
            self.error = "Failed to load effects: \(error.localizedDescription)"
        }

        return []
    }

    func updateEffect(to index: Int) async {
        do {
            try await deviceStore.updateEffect(host: host, index: index)
        } catch {
            self.error = "Failed to update effect: \(error.localizedDescription)"
        }
    }

    func clearError() {
        error = nil
    }
}
