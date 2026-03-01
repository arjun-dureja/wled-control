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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            HeaderView(
                device: $viewModel.device,
                isLoading: viewModel.isLoading,
                onTogglePower: { isOn in
                    Task {
                        await viewModel.updatePower(to: isOn)
                    }
                },
                onNicknameChanged: { nickname in
                    viewModel.updateNickname(nickname)
                }
            )
            Spacer()

            Grid(horizontalSpacing: 20, verticalSpacing: 20)  {
                GridRow {
                    OptionButton(systemImage: "switch.2", text: "Controls") {
                        navigationService.navigate(
                            to: .controls(
                                controlsViewModel: ControlsViewModel(service: viewModel.service)
                            )
                        )
                    }
                    OptionButton(systemImage: "paintpalette.fill", text: "Colors") {
                        navigationService.navigate(
                            to: .colors(
                                colorsViewModel: ColorsViewModel(service: viewModel.service)
                            )
                        )
                    }
                }
                GridRow {
                    OptionButton(systemImage: "flame.fill", text: "Effects") {
                        navigationService.navigate(
                            to: .effects(
                                effectsViewModel: EffectsViewModel(service: viewModel.service)
                            )
                        )
                    }
                    OptionButton(systemImage: "swatchpalette.fill", text: "Palettes") {
                        navigationService.navigate(
                            to: .palettes(
                                palettesViewModel: PalettesViewModel(service: viewModel.service)
                            )
                        )
                    }
                }
            }

            Spacer()
            FooterView()
        }
        .onAppear {
            viewModel.onDeviceOffline = {
                navigationService.goBackToRoot()
            }
            viewModel.startHeartbeat()
        }
        .onDisappear {
            viewModel.stopHeartbeat()
        }
    }

    private func OptionButton(systemImage: String, text: String, onPress: @escaping () -> Void) -> some View {
        Button {
            onPress()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 30))

                Text(text)
                    .font(.system(size: 15))
            }
            .frame(width: 100, height: 100)
            .padding()
        }
        .buttonStyle(BlueButtonStyle())

    }
}

#Preview {
    DetailView(
        viewModel: DetailViewModel(
            service: WLEDService(ipAddr: "10.0.0.219")
        )
    )
    .frame(width: 330, height: 440)
}
