//
//  ContentView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2023-11-13.
//

import SwiftUI

struct ContentView: View {
    @StateObject var navigationService = NavigationService()
    @StateObject var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack(path: self.$navigationService.navigationPath) {
            HomeView(viewModel: homeViewModel)
        .navigationDestination(for: NavigationService.Destination.self) { destination in
            switch destination {
            case .addDevice(let addDeviceViewModel):
                AddDeviceView(viewModel: addDeviceViewModel)
            case .detail(let detailViewModel):
                DetailView(viewModel: detailViewModel)
            case .controls(let controlsViewModel):
                ControlsView(viewModel: controlsViewModel)
            case .colors(let colorsViewModel):
                ColorsView(viewModel: colorsViewModel)
            case .effects(let effectsViewModel):
                EffectsView(viewModel: effectsViewModel)
            case .palettes(let palettesViewModel):
                PalettesView(viewModel: palettesViewModel)
            }
        }
        }
        .environmentObject(navigationService)
        .frame(width: 300, height: 400)
        .appBackground()
    }
}

#Preview {
    ContentView()
}
