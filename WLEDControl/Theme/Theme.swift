//
//  Theme.swift
//  WLEDControl
//

import SwiftUI

enum Theme {
    // MARK: - Background Colors
    enum Background {
        static let darkStart = Color(red: 26/255, green: 27/255, blue: 30/255)
        static let darkMiddle = Color(red: 28/255, green: 28/255, blue: 30/255)
        static let darkEnd = Color(red: 44/255, green: 44/255, blue: 46/255)
        
        static let lightStart = Color(red: 245/255, green: 245/255, blue: 247/255)
        static let lightMiddle = Color(red: 232/255, green: 232/255, blue: 237/255)
        static let lightEnd = Color(red: 209/255, green: 209/255, blue: 214/255)
    }
    
    // MARK: - Card Colors
    enum Card {
        static let darkFill = Color(red: 30/255, green: 30/255, blue: 30/255, opacity: 0)
        static let darkFillEnd = Color(red: 48/255, green: 48/255, blue: 48/255, opacity: 0.5)
        
        static let lightFill = Color.white.opacity(0.8)
        static let lightFillEnd = Color(red: 245/255, green: 245/255, blue: 245/255, opacity: 0.5)
    }
    
    // MARK: - Border Colors
    enum Border {
        static let dark = Color(red: 58/255, green: 58/255, blue: 58/255)
        static let light = Color(red: 200/255, green: 200/255, blue: 200/255)
    }
    
    // MARK: - Icon Background
    enum Icon {
        static let dark = Color(red: 40/255, green: 40/255, blue: 40/255)
        static let light = Color(red: 240/255, green: 240/255, blue: 240/255)
    }
    
    // MARK: - Text Field
    enum TextField {
        static let dark = Color(red: 40/255, green: 40/255, blue: 40/255)
        static let light = Color(red: 240/255, green: 240/255, blue: 240/255)
    }
    
    // MARK: - Status Colors
    enum Status {
        static let online = Color.green
        static let offline = Color.red
        static let connecting = Color.orange
    }
    
    // MARK: - Accent
    enum Accent {
        static let blue = Color(red: 92/255, green: 162/255, blue: 220/255)
        static let wledDefault = Color.orange
    }
}

// MARK: - View Modifiers

struct CardBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Theme.Card.darkFill, Theme.Card.darkFillEnd]
                        : [Theme.Card.lightFill, Theme.Card.lightFillEnd],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(colorScheme == .dark ? Theme.Border.dark : Theme.Border.light, lineWidth: 1)
            }
    }
}

struct IconBadge: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(width: 36, height: 36)
            .background(colorScheme == .dark ? Theme.Icon.dark : Theme.Icon.light)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
    
    func iconBadge() -> some View {
        modifier(IconBadge())
    }
}
