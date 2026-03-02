//
//  ColorPanel.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-29.
//

import AppKit
import SwiftUI

struct ColorWheel: View {
    @Binding var selectedColor: NSColor
    @State private var indicatorPosition: CGPoint = .zero

    let onChange: () -> Void

    let angularGradient: Gradient = {
        Gradient(colors: (0..<360).map {
            Color(hue: Double($0) / 360, saturation: 1, brightness: 1)
        })
    }()

    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.radius()

            ZStack {
                AngularGradient(
                    gradient: angularGradient,
                    center: .center
                )
                .mask(Circle())
                .overlay(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white, Color.white.opacity(0)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )

                // Color indicator
                Circle()
                    .fill(Color(selectedColor))
                    .stroke(Color.black.opacity(0.8), lineWidth: 2)
                    .frame(width: 15, height: 15)
                    .shadow(radius: 2)
                    .position(indicatorPosition)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateColor(at: value.location, in: geometry.size)
                }
                .onEnded { _ in
                    onChange()
                }
            )
            .shadow(radius: 16)
            .onAppear {
                updateIndicatorPosition(for: selectedColor, in: geometry.size)
            }
            .onChange(of: selectedColor) { _, newValue in
                updateIndicatorPosition(for: newValue, in: geometry.size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func updateColor(at point: CGPoint, in size: CGSize) {
        let center = size.center()
        let radius = size.radius()
        let distance = point.distance(to: center)

        // The point should be inside of the circle
        guard distance <= radius else {
            // Constrain the point to the edge of the circle if outside the radius
            let constrainedPoint = point.constrained(toRadius: radius, around: center)
            self.indicatorPosition = constrainedPoint
            self.selectedColor = color(at: constrainedPoint, in: size)
            return
        }

        self.indicatorPosition = point
        self.selectedColor = color(at: point, in: size)
    }

    private func color(at point: CGPoint, in size: CGSize) -> NSColor {
        let center = size.center()
        let angle = center.angle(to: point)

        // Hue is the angle around the circle - normalized between 0 and 1
        let hue = (angle < 0 ? angle + 2 * .pi : angle) / (2 * .pi)
        let radius = size.radius()
        let distance = point.distance(to: center)

        // Saturation is the distance from the center of the circle - normalized between 0 and 1
        let saturation = min(distance / radius, 1.0)

        return NSColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
    }

    private func updateIndicatorPosition(for color: NSColor, in size: CGSize) {
        let radius = size.radius()
        let center = size.center()

        // Needs to be converted to sRGB or else getHue could fail
        let srgbColor = color.usingColorSpace(.sRGB)
        if let srgbColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            srgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

            let angle = hue * 2 * .pi
            let distance = saturation * radius
            let x = center.x + distance * cos(angle)
            let y = center.y + distance * sin(angle)
            self.indicatorPosition = CGPoint(x: x, y: y)
        }
    }
}

#Preview {
    ColorWheel(selectedColor: .constant(NSColor.white)) { }
        .frame(width: 200, height: 200)
}
