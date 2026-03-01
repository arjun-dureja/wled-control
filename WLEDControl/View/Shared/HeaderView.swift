//
//  HeaderView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var navigationService: NavigationService

    @Binding var device: WLEDDevice
    var isLoading: Bool = false

    let onTogglePower: (Bool) -> Void
    var onNicknameChanged: ((String) -> Void)?

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
                            Text(device.nickname)
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

                    Text(device.ipAddress)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !isLoading {
                    Toggle(isOn: Binding(
                        get: { device.isOn },
                        set: { newValue in
                            onTogglePower(newValue)
                        })) {
                            Text("")
                        }
                        .toggleStyle(SwitchToggleStyle())
                        .tint(Theme.Accent.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()
        }
    }

    private func startEditing() {
        editedNickname = device.nickname
        isEditingNickname = true
        isTextFieldFocused = true
    }

    private func saveNickname() {
        let trimmed = editedNickname.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            device.nickname = trimmed
            onNicknameChanged?(trimmed)
        }
        isEditingNickname = false
        isTextFieldFocused = false
    }
}
