import SwiftUI

public struct RenderedIf: ViewModifier {
    let condition: Bool
    
    public init(_ condition: Bool) {
        self.condition = condition
    }
    
    public func body(content: Content) -> some View {
        RenderIf(condition) {
            content
        }
    }
}

public extension View {
    
    func renderedIf(_ condition: Bool) -> some View {
        modifier(RenderedIf(condition))
    }
}
