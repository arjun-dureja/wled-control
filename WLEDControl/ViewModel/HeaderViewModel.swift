//
//  HeaderViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import Foundation
import Combine

@MainActor
class HeaderViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var error: String?
    
    let host: String
    private let deviceStore: DeviceStore
    private var cancellables = Set<AnyCancellable>()

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
    
    func updatePower(to isOn: Bool) async {
        device.isOn = isOn
        
        do {
            try await deviceStore.updatePower(host: host, isOn: isOn)
        } catch {
            device.isOn = !isOn
            self.error = "Failed to update power: \(error.localizedDescription)"
        }
    }
    
    func updateNickname(_ nickname: String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        deviceStore.renameDevice(host: host, nickname: trimmed)
    }
    
    func clearError() {
        error = nil
    }
}
