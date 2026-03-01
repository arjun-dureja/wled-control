//
//  BlueButtonStyle.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-30.
//

import SwiftUI

struct BlueButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? (colorScheme == .dark
                        ? LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color.black.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                    : (colorScheme == .dark
                        ? LinearGradient(colors: [Theme.Card.darkFill, Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Theme.Card.lightFill, Theme.Card.lightFillEnd], startPoint: .top, endPoint: .bottom))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Theme.Border.dark : Theme.Border.light, lineWidth: 1)
            }
    }
}
