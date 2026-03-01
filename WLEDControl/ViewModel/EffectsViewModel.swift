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

    func updatePower(to isOn: Bool) async {
        // Optimistic update
        self.device.isOn = isOn

        do {
            let payload = StateUpdatePayload(on: isOn)
            try await service.sendStateUpdate(payload: payload)
        } catch {
            self.device.isOn = !isOn
        }
    }

    func getEffects() async -> [Effect] {
        do {
            return try await service.getEffects()
        } catch {
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
        }
    }
}
