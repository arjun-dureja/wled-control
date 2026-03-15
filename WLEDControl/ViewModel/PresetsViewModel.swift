//
//  PresetsViewModel.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class PresetsViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published private(set) var error: String?

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

    func getPresets() async -> [Preset] {
        do {
            return try await deviceStore.getPresets(host: host)
        } catch {
            self.error = "Failed to load presets: \(error.localizedDescription)"
        }

        return []
    }

    func updatePreset(to index: Int) async {
        do {
            try await deviceStore.updatePreset(host: host, index: index)
        } catch {
            self.error = "Failed to update preset: \(error.localizedDescription)"
        }
    }

    func clearError() {
        error = nil
    }
}
