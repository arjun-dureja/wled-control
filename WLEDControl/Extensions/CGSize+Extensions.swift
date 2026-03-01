//
//  CGSize+Extensions.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-05.
//

import Foundation

extension CGSize {
    func center() -> CGPoint {
        CGPoint(x: self.width / 2, y: self.height / 2)
    }

    func radius() -> CGFloat {
        min(self.width, self.height) / 2
    }
}

