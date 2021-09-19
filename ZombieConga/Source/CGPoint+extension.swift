//
//  CGPoint+extension.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 19.09.2021.
//

import CoreGraphics

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    func normalized() -> CGPoint {
        return self / length()
    }

    var angle: CGFloat {
        return atan2(y, x)
    }
}
