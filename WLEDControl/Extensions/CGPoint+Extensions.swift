//
//  CGPoint+Extensions.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-05.
//

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    // Angle from x-axis to point
    func angle(to point: CGPoint) -> CGFloat {
        atan2(point.y - self.y, point.x - self.x)
    }

    func constrained(toRadius radius: CGFloat, around center: CGPoint) -> CGPoint {
        let angle = center.angle(to: self)

        // Point on the edge of the circle for the given angle
        let constrainedX = center.x + radius * cos(angle)
        let constrainedY = center.y + radius * sin(angle)
        return CGPoint(x: constrainedX, y: constrainedY)
    }
}
