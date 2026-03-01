//
//  ColorsViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ColorsViewModel: ObservableObject {
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

    func updateColor(index: Int, color: [Int]) async {
        var segments = [[Int]](repeating: [], count: 3)
        segments[index] = color
        await self.sendUpdate(payload: StateUpdatePayload(seg: [.init(col: segments)]))
    }

    private func sendUpdate(payload: StateUpdatePayload) async {
        do {
            try await service.sendStateUpdate(payload: payload)
        } catch {
        }
    }
}
