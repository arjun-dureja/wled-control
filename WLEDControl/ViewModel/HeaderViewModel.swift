//
//  HeaderViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import Foundation
import Combine

class HeaderViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var error: String?
    
    let service: WLEDService
    private var cancellables = Set<AnyCancellable>()

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
        device.isOn = isOn
        
        do {
            let payload = StateUpdatePayload(on: isOn)
            try await service.sendStateUpdate(payload: payload)
        } catch {
            device.isOn = !isOn
            self.error = "Failed to update power: \(error.localizedDescription)"
        }
    }
    
    func updateNickname(_ nickname: String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        device.nickname = trimmed
        service.device.nickname = trimmed
        service.deviceSubject.send(device)
        DeviceStorage.shared.updateNickname(for: device.ipAddress, nickname: trimmed)
        NotificationCenter.default.post(name: HomeViewModel.devicesDidChange, object: nil)
    }
    
    func clearError() {
        error = nil
    }
}
