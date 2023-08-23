import SwiftUI

//MARK: Custom Animation Curves
extension Animation {
    //A snappy swipe gesture
    static var swipeIn: Animation {
        .timingCurve(0.9, -0.05, 0.66, 0.59, duration: 1.2)
    }
    
    //Entry/Exit modals
    static var modalEntry: Animation {
        .interpolatingSpring(stiffness: 300.0,
                             damping: 30.0,
                             initialVelocity: 10.0)
    }
}

extension View {
    func cancelAnimations() -> some View {
        self.animation(nil, value: true)
        .transaction { tx in
            tx.animation = nil
        }
    }
}
