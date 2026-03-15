//
//  PresetsView.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import SwiftUI

struct PresetsView: View {
    @ObservedObject var viewModel: PresetsViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var presets: [Preset] = []
    @State private var searchText = ""

    private var filteredPresets: [Preset] {
        if searchText.isEmpty {
            return presets
        } else {
            return presets.filter { $0.name.localizedStandardContains(searchText) }
        }
    }

    private var deviceURL: URL? {
        URL(string: "http://\(viewModel.host)")
    }

    var body: some View {
        DeviceScreen(host: viewModel.host) {
            if presets.isEmpty {
                emptyState
                    .padding(.horizontal, 12)
                    .padding(.top)
            } else {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPresets) { preset in
                            Button {
                                Task {
                                    await viewModel.updatePreset(to: preset.index)
                                }
                            } label: {
                                HStack {
                                    Text(preset.name)
                                        .font(.title3)
                                        .foregroundStyle(
                                            viewModel.device.preset == preset.index ? Theme.Accent.blue : .primary
                                        )
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Image(systemName: viewModel.device.preset == preset.index ? "checkmark" : "bookmark.fill")
                                        .foregroundStyle(
                                            viewModel.device.preset == preset.index ? Theme.Accent.blue : .primary
                                        )
                                        .opacity(viewModel.device.preset == preset.index ? 1 : 0.5)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(rowBackground(isSelected: viewModel.device.preset == preset.index))
                                .clipShape(.rect(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(borderColor, lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 12)
            }
        }
        .onAppear {
            Task {
                presets = await viewModel.getPresets()
            }
        }
        .onChange(of: viewModel.error) { _, newError in
            if let error = newError {
                showErrorAlert(message: error)
                viewModel.clearError()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No presets found")
                .font(.title3)
                .bold()

            Text("Create a preset in your WLED config, then return here to apply it.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let deviceURL {
                Link(viewModel.host, destination: deviceURL)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func rowBackground(isSelected: Bool) -> some ShapeStyle {
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
