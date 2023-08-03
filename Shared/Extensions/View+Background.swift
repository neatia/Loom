import Foundation
import SwiftUI

extension View {
    
    public func backgroundIf<Background : View>(_ condition : Bool, alignment : Alignment = .center, overlay : Background) -> some View {
        self.background(condition ? background() : nil, alignment: alignment)
    }
    
    public func backgroundIf<Background : View>(_ condition : Bool, alignment : Alignment = .center, @ViewBuilder background : () -> Background) -> some View {
        self.background(condition ? background() : nil, alignment: alignment)
    }
    
}
