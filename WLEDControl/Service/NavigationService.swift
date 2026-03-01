//
//  NavigationService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-03.
//

import Foundation
import SwiftUI

@MainActor
final class NavigationService: ObservableObject {
    @Published var navigationPath = NavigationPath()

    public enum Destination {
        case addDevice(addDeviceViewModel: AddDeviceViewModel)
        case detail(detailViewModel: DetailViewModel)
        case controls(controlsViewModel: ControlsViewModel)
        case colors(colorsViewModel: ColorsViewModel)
        case effects(effectsViewModel: EffectsViewModel)
        case palettes(palettesViewModel: PalettesViewModel)
    }

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }

    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func goBackToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}

extension NavigationService.Destination: Hashable {
    var id: UUID {
        switch self {
        case .addDevice(let addDeviceViewModel):
            return addDeviceViewModel.id
        case .detail(let detailViewModel):
            return detailViewModel.id
        case .controls(let controlsViewModel):
            return controlsViewModel.id
        case .colors(let colorsViewModel):
            return colorsViewModel.id
        case .effects(let effectsViewModel):
            return effectsViewModel.id
        case .palettes(let palettesViewModel):
            return palettesViewModel.id
        }
    }

    static func == (lhs: NavigationService.Destination, rhs: NavigationService.Destination) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
