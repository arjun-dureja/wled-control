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

    func updateBrightness(to value: Double) async {
        await sendUpdate(payload: StateUpdatePayload(bri: Int(value)))
    }

    func updateEffectSpeed(to value: Double) async {
        await sendUpdate(payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(sx: Int(value))]))
    }

    func updateEffectSize(to value: Double) async {
        await sendUpdate(payload: StateUpdatePayload(seg: [StateUpdatePayload.Seg(ix: Int(value))]))
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

    private func sendUpdate(payload: StateUpdatePayload) async {
        do {
            try await service.sendStateUpdate(payload: payload)
        } catch {
        }
    }
}
