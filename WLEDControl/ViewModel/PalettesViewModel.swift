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
        self.device.isOn = isOn

        do {
            let payload = StateUpdatePayload(on: isOn)
            try await service.sendStateUpdate(payload: payload)
        } catch {
            self.device.isOn = !isOn
        }
    }

    func getPalettes() async -> [Palette] {
        do {
            return try await service.getPalettes()
        } catch {
        }

        return []
    }

    func updatePalette(to index: Int) async {
        do {
            let payload = StateUpdatePayload(
                seg: [StateUpdatePayload.Seg(pal: index)]
            )
            try await service.sendStateUpdate(payload: payload)
        } catch {
        }
    }
}
