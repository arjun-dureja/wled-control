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

    private let optionSpacing: CGFloat = 14
    private let optionSize: CGFloat = 115

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            VStack(spacing: optionSpacing) {
                Grid(horizontalSpacing: optionSpacing, verticalSpacing: optionSpacing) {
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

                PresetsButton {
                    navigationService.navigate(
                        to: .presets(
                            presetsViewModel: PresetsViewModel(host: viewModel.host)
                        )
                    )
                }
            }
            .padding(.top, 12)
        }
    }

    private func OptionButton(systemImage: String, text: String, onPress: @escaping () -> Void) -> some View {
        Button {
            onPress()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))

                Text(text)
                    .font(.headline)
            }
            .frame(width: optionSize, height: optionSize)
        }
        .buttonStyle(BlueButtonStyle())
    }

    private func PresetsButton(onPress: @escaping () -> Void) -> some View {
        Button {
            onPress()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 18))

                Text("Presets")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal)
        }
        .buttonStyle(BlueButtonStyle())
        .padding(.horizontal, 18)
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
