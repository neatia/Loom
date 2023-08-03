import CoreGraphics

public extension Double {
    
    func random() -> Double {
        self * Double.random(in: 0...1)
    }
}
