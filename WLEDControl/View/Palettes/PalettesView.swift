//
//  PalettesView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-21.
//

import SwiftUI

struct PalettesView: View {
    @ObservedObject var viewModel: PalettesViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var palettes: [Palette] = []
    @State private var searchText = ""

    var filteredPalettes: [Palette] {
        if searchText.isEmpty {
            return palettes
        } else {
            return palettes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPalettes.indices, id: \.self) { index in
                        if filteredPalettes[index].name != "RSVD" && filteredPalettes[index].name != "-" {
                            Button {
                                Task {
                                    await viewModel.updatePalette(to: filteredPalettes[index].index)
                                }
                            } label: {
                                HStack {
                                    Text(filteredPalettes[index].name)
                                        .font(.title3)
                                        .foregroundColor(viewModel.device.palette == filteredPalettes[index].index ? Theme.Accent.blue : .primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Image(systemName: viewModel.device.palette == filteredPalettes[index].index ? "checkmark" : "paintpalette.fill")
                                        .foregroundColor(viewModel.device.palette == filteredPalettes[index].index ? Theme.Accent.blue : .primary)
                                        .opacity(viewModel.device.palette == filteredPalettes[index].index ? 1 : 0.5)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(paletteRowBackground(isSelected: viewModel.device.palette == filteredPalettes[index].index))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(borderColor, lineWidth: 1)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            Task {
                self.palettes = await viewModel.getPalettes()
            }
        }
        .onChange(of: viewModel.error) {
            if let error = viewModel.error {
                showErrorAlert(message: error)
                viewModel.clearError()
            }
        }
    }

    private func paletteRowBackground(isSelected: Bool) -> some ShapeStyle {
        if isSelected {
            return LinearGradient(colors: [Theme.Accent.blue.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        } else if colorScheme == .dark {
            return LinearGradient(
                colors: [Theme.Card.darkFill, Theme.Card.darkFillEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Theme.Card.lightFill, Theme.Card.lightFillEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var borderColor: Color {
        colorScheme == .dark ? Theme.Border.dark : Theme.Border.light
    }
}
