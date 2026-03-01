//
//  ContentView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2023-11-13.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var navigationService = NavigationService()
    @StateObject var homeViewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme

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
        .frame(width: 330, height: 440)
        .background(
            ZStack {
                if colorScheme == .dark {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#1A1B1E"),
                            Color(hex: "#1C1C1E"),
                            Color(hex: "#2C2C2E")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#0066FF").opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FF3CAC").opacity(0.05),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.8, y: 0.2),
                        startRadius: 0,
                        endRadius: 150
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#0066FF").opacity(0.1),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.2, y: 0.8),
                        startRadius: 0,
                        endRadius: 150
                    )
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#F5F5F7"),
                            Color(hex: "#E8E8ED"),
                            Color(hex: "#D1D1D6")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#0066FF").opacity(0.08),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FF3CAC").opacity(0.03),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.8, y: 0.2),
                        startRadius: 0,
                        endRadius: 150
                    )

                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#0066FF").opacity(0.05),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.2, y: 0.8),
                        startRadius: 0,
                        endRadius: 150
                    )
                }
            }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.2))
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 10, x: 0, y: 4)
        )
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}