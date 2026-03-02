//
//  ColorsSegmentedControl.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2026-03-01.
//

import SwiftUI

struct ColorSegmentedControl: View {
    @Environment(\.colorScheme) private var colorScheme

    let labels: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(labels.indices, id: \.self) { index in
                Button {
                    selection = index
                } label: {
                    Text(labels[index])
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .foregroundStyle(selection == index ? .white : .primary)
                .background(selection == index ? Theme.Accent.blue : .clear)
                .clipShape(.rect(cornerRadius: 8))
            }
        }
        .background(
            colorScheme == .dark
            ? Theme.TextField.dark.opacity(0.7)
            : Theme.TextField.light
        )
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    colorScheme == .dark ? Theme.Border.dark : Theme.Border.light,
                    lineWidth: 1
                )
        )
    }
}

