import SwiftUI

public extension Int {
    
    var asString: String {
        String(self)
    }
    
    func clamped(to: Int, spanZero: Bool = false) -> Int {
        self.clamped(from: spanZero ? -to : 0, to: to)
    }

    var isPositive: Bool {
        return self >= 0
    }

    var clampedPositive: Int {
        return isPositive ? self : 0
    }

    var clampedNegative: Int {
        return isPositive ? 0 : self
    }

    var isNegative: Bool {
        !isPositive
    }

    var isEven: Bool {
        self.isMultiple(of: 2)
    }
    
    var isOdd: Bool {
        !isEven
    }
    
    func random() -> Int {
        Int.random(in: 0...self)
    }
}


