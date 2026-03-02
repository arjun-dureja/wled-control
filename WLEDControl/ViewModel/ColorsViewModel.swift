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

    func updateColor(index: Int, color: [Int]) async -> Bool {
        do {
            try await deviceStore.updateColor(host: host, index: index, color: color)
            return true
        } catch {
            self.error = "Failed to update color: \(error.localizedDescription)"
            return false
        }
    }

    func clearError() {
        error = nil
    }
}
