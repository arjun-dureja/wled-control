//
//  ControlsView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-03.
//

import SwiftUI
import ModernSlider

struct ControlsView: View {
    @ObservedObject var viewModel: ControlsViewModel

    private let sliderWidth: CGFloat = 240

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            VStack(spacing: 26) {
                ModernSlider(
                    "Brightness",
                    systemImage: "sun.max.fill",
                    sliderWidth: sliderWidth,
                    value: $viewModel.device.brightness,
                    onChangeEnd: { newValue in
                        Task {
                            let updatedBrightness = 254 * (Double(newValue) / 100) + 1
                            await viewModel.updateBrightness(to: updatedBrightness)
                        }
                    }
                )

                ModernSlider(
                    "Effect Speed",
                    systemImage: "speedometer",
                    sliderWidth: sliderWidth,
                    value: $viewModel.device.effectSpeed,
                    onChangeEnd: {  newValue in
                        Task {
                            let updatedSpeed = Double(255 * (newValue / 100))
                            await viewModel.updateEffectSpeed(to: updatedSpeed)
                        }
                    }
                )

                ModernSlider(
                    "Effect Size",
                    systemImage: "flame.fill",
                    sliderWidth: sliderWidth,
                    value: $viewModel.device.effectSize,
                    onChangeEnd: { newValue in
                        Task {
                            let updatedSize = Double(255 * (newValue / 100))
                            await viewModel.updateEffectSize(to: updatedSize)
                        }
                    }
                )
            }
            .padding(.top)
        }
        .onChange(of: viewModel.error) { _, newError in
            if let error = newError {
                showErrorAlert(message: error)
                viewModel.clearError()
            }
        }
    }
}
