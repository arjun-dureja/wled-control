//
//  PalettesViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-21.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class PalettesViewModel: ObservableObject {
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

    func getPalettes() async -> [Palette] {
        do {
            return try await deviceStore.getPalettes(host: host)
        } catch {
            self.error = "Failed to load palettes: \(error.localizedDescription)"
        }

        return []
    }

    func updatePalette(to index: Int) async {
        do {
            try await deviceStore.updatePalette(host: host, index: index)
        } catch {
            self.error = "Failed to update palette: \(error.localizedDescription)"
        }
    }

    func clearError() {
        error = nil
    }
}
