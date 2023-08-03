import Foundation
import SwiftUI

public extension UnitPoint {
    
    init<TX: UINumericType, TY: UINumericType>(_ x: TX, _ y: TY) {
        self.init(x: x.asCGFloat, y: y.asCGFloat)
    }
    
    var asCGPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    func inverted() -> UnitPoint {
        UnitPoint(1 - x, 1 - y)
    }
}

// MARK: -- ANGLES

private let maxUnitRadius = sqrt(0.5 * 0.5 + 0.5 * 0.5)
private let centerPoint = CGPoint(x: 0.5, y: 0.5)

private let angleForNamedUnitPoint: [UnitPoint: Angle] = [

    .topLeading: .topLeading,
    .top: .top,
    .topTrailing: .topTrailing,
    .trailing: .trailing,
    .bottomTrailing: .bottomTrailing,
    .bottom: .bottom,
    .bottomLeading: .bottomLeading,
    .leading: .leading,
]

public extension UnitPoint {
    
    var asAngle: Angle {
        if let angle = angleForNamedUnitPoint[self] {
            return angle
        } else {
            return centerPoint.angleTo(self.asCGPoint)
        }
    }
}
