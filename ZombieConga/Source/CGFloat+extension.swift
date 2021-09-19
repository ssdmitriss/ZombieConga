//
//  CGFloat+extension.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 19.09.2021.
//

import CoreGraphics

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }

    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }

    func sign() -> CGFloat {
        return self >= 0.0 ? 1.0 : -1.0
    }
}
