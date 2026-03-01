//
//  HeaderView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var navigationService: NavigationService
    @StateObject var viewModel: HeaderViewModel

    @State private var isEditingNickname = false
    @State private var editedNickname = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    navigationService.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .frame(height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        if isEditingNickname {
                            TextField("Device name", text: $editedNickname)
                                .font(.title2)
                                .textFieldStyle(.plain)
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    saveNickname()
                                }
                                .frame(maxWidth: 150)
                        } else {
                            Text(viewModel.device.nickname)
                                .font(.title2)

                            Button {
                                startEditing()
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .offset(y: -1)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(viewModel.device.ipAddress)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Toggle(isOn: Binding(
                    get: { viewModel.device.isOn },
                    set: { newValue in
                        Task {
                            await viewModel.updatePower(to: newValue)
                        }
                    })) {
                        Text("")
                    }
                    .toggleStyle(SwitchToggleStyle())
                    .tint(Theme.Accent.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()
        }
        .onChange(of: viewModel.error) { _, newError in
            if let error = newError {
                showErrorAlert(message: error)
                viewModel.clearError()
            }
        }
    }

    private func startEditing() {
        editedNickname = viewModel.device.nickname
        isEditingNickname = true
        isTextFieldFocused = true
    }

    private func saveNickname() {
        let trimmed = editedNickname.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            viewModel.updateNickname(trimmed)
        }
        isEditingNickname = false
        isTextFieldFocused = false
    }
}
