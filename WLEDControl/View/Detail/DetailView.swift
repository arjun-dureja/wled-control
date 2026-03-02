//
//  DetailView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-30.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var navigationService: NavigationService
    @ObservedObject var viewModel: DetailViewModel

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            Grid(horizontalSpacing: 18, verticalSpacing: 18) {
                GridRow {
                    OptionButton(systemImage: "switch.2", text: "Controls") {
                        navigationService.navigate(
                            to: .controls(
                                controlsViewModel: ControlsViewModel(host: viewModel.host)
                            )
                        )
                    }
                    OptionButton(systemImage: "paintpalette.fill", text: "Colors") {
                        navigationService.navigate(
                            to: .colors(
                                colorsViewModel: ColorsViewModel(host: viewModel.host)
                            )
                        )
                    }
                }
                GridRow {
                    OptionButton(systemImage: "flame.fill", text: "Effects") {
                        navigationService.navigate(
                            to: .effects(
                                effectsViewModel: EffectsViewModel(host: viewModel.host)
                            )
                        )
                    }
                    OptionButton(systemImage: "swatchpalette.fill", text: "Palettes") {
                        navigationService.navigate(
                            to: .palettes(
                                palettesViewModel: PalettesViewModel(host: viewModel.host)
                            )
                        )
                    }
                }
            }
            .padding(.top)
        }
    }

    private func OptionButton(systemImage: String, text: String, onPress: @escaping () -> Void) -> some View {
        Button {
            onPress()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 27))

                Text(text)
                    .font(.system(size: 14))
            }
            .frame(width: 85, height: 85)
            .padding()
        }
        .buttonStyle(BlueButtonStyle())

    }
}

#Preview {
    DetailView(
        viewModel: DetailViewModel(
            host: "10.0.0.219"
        )
    )
    .frame(width: 330, height: 440)
}
