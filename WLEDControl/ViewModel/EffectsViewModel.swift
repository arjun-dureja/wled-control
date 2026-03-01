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

    let service: WLEDService
    private var cancellables = Set<AnyCancellable>()
    let id = UUID()

    init(service: WLEDService) {
        self.service = service
        self.device = service.device

        service.devicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.device = device
            }
            .store(in: &cancellables)
    }

    func getEffects() async -> [Effect] {
        do {
            return try await service.getEffects()
        } catch {
            self.error = "Failed to load effects: \(error.localizedDescription)"
        }

        return []
    }

    func updateEffect(to index: Int) async {
        do {
            let payload = StateUpdatePayload(
                seg: [StateUpdatePayload.Seg(fx: index)]
            )
            try await service.sendStateUpdate(payload: payload)
        } catch {
            self.error = "Failed to update effect: \(error.localizedDescription)"
        }
    }

    func clearError() {
        error = nil
    }
}
