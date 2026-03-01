//
//  EffectsView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-05.
//

import SwiftUI

struct EffectsView: View {
    @EnvironmentObject var navigationService: NavigationService
    @ObservedObject var viewModel: EffectsViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var effects: [Effect] = []
    @State private var searchText = ""

    var filteredEffects: [Effect] {
        if searchText.isEmpty {
            return effects
        } else {
            return effects.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HeaderView(device: $viewModel.device) { isOn in
                Task {
                    await viewModel.updatePower(to: isOn)
                }
            }

            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredEffects.indices, id: \.self) { index in
                        if filteredEffects[index].name != "RSVD" && filteredEffects[index].name != "-" {
                            Button {
                                Task {
                                    await viewModel.updateEffect(to: filteredEffects[index].index)
                                }
                            } label: {
                                HStack {
                                    Text(filteredEffects[index].name)
                                        .font(.title3)
                                        .foregroundColor(viewModel.device.effect == filteredEffects[index].index ? Theme.Accent.blue : .primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Image(systemName: viewModel.device.effect == filteredEffects[index].index ? "checkmark" : "flame.fill")
                                        .foregroundColor(viewModel.device.effect == filteredEffects[index].index ? Theme.Accent.blue : .primary)
                                        .opacity(viewModel.device.effect == filteredEffects[index].index ? 1 : 0.5)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(effectRowBackground(isSelected: viewModel.device.effect == filteredEffects[index].index))
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

            Spacer()
            FooterView()
        }
        .onAppear {
            Task {
                self.effects = await viewModel.getEffects()
            }
        }
    }

    private func effectRowBackground(isSelected: Bool) -> some ShapeStyle {
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
