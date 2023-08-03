import Foundation
import SwiftUI

extension View {
    
    public func overlayIf<Overlay : View>(_ condition : Bool, alignment : Alignment = .center, overlay : Overlay) -> some View {
        self.overlay(condition ? overlay : nil, alignment: alignment)
    }
    
    public func overlayIf<Overlay : View>(_ condition : Bool, alignment : Alignment = .center, @ViewBuilder overlay : () -> Overlay) -> some View {
        self.overlay(condition ? overlay() : nil, alignment: alignment)
    }
    
}
