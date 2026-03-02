//
//  ColorsView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import SwiftUI

struct ColorsView: View {
    @StateObject var viewModel: ColorsViewModel

    @State private var selectedColor = NSColor.white
    @State private var selectedTab = 0
    @State private var deviceColors: [NSColor] = []
    @State private var hexValue = ""

    @FocusState private var isFocused: Bool

    private let colorLabels = ["Color 1", "Color 2", "Color 3"]

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            VStack(spacing: 24) {
                Picker("", selection: $selectedTab) {
                    ForEach(colorLabels.indices, id: \.self) { index in
                        Text(colorLabels[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedTab) { _, newValue in
                    selectedColor = deviceColors[newValue]
                }

                VStack(spacing: 16) {
                    ColorWheel(selectedColor: $selectedColor) {
                        handleColorChanged()
                        isFocused = false
                    }
                    .frame(width: 200, height: 200)
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(selectedColor))
                            .frame(width: 30, height: 30)
                        
                        TextField("Hex", text: $hexValue)
                            .onChange(of: hexValue) {
                                let hex = hexValue.replacingOccurrences(of: "#", with: "")
                                guard hex.count == 6 && hex.allSatisfy(\.isHexDigit) else {
                                    return
                                }
                                
                                selectedColor = NSColor(hex: hex)
                                handleColorChanged()
                            }
                            .frame(width: 100)
                            .controlSize(.large)
                            .textFieldStyle(.roundedBorder)
                            .focused($isFocused)
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal, 12)
        }
        .onAppear {
            updateDeviceColors()

            // Hack to disable textfield auto-focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = false
            }
        }
        .onChange(of: viewModel.device.colors) {
            updateDeviceColors()
        }
        .onChange(of: viewModel.error) { _, newError in
            if let error = newError {
                showErrorAlert(message: error)
                viewModel.clearError()
            }
        }
    }

    private func handleColorChanged() {
        Task {
            await updateColor()
            hexValue = ""
        }
    }

    // Needed to keep local device colors array in sync with colors from view model
    private func updateDeviceColors() {
        deviceColors = [
            viewModel.device.colors.colorOne.nsColor,
            viewModel.device.colors.colorTwo.nsColor,
            viewModel.device.colors.colorThree.nsColor
        ]
        selectedColor = deviceColors[selectedTab]
    }

    private func updateColor() async {
        // Avoid redundant network requests
        guard self.selectedColor != deviceColors[selectedTab] else { return }

        let color = Color(selectedColor).toRGB()
        let rgb = [color.0, color.1, color.2]

        let didUpdate = await viewModel.updateColor(index: selectedTab, color: rgb)
        guard didUpdate else { return }

        var updatedDeviceColors = deviceColors
        updatedDeviceColors[selectedTab] = selectedColor
        viewModel.device.colors = WLEDColors(
            colorOne: WLEDColor(nsColor: updatedDeviceColors[0]),
            colorTwo: WLEDColor(nsColor: updatedDeviceColors[1]),
            colorThree: WLEDColor(nsColor: updatedDeviceColors[2])
        )

    }
}
