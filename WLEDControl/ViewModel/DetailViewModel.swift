//
//  DetailViewModel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-01.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
    @Published var device: WLEDDevice
    @Published var isLoading = true

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

        deviceStore.initialStatePublisher(for: host)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

}
