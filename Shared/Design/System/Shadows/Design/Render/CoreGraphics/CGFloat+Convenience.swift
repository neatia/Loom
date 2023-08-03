import CoreGraphics

public extension CGFloat {
    
    func random() -> CGFloat {
        self * CGFloat.random(in: 0...1)
    }
}
