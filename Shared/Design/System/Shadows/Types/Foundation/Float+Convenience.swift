import CoreGraphics

public extension Float {
    
    func random() -> Float {
        self * Float.random(in: 0...1)
    }
}
