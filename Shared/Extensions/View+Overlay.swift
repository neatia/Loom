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

extension View {
    func wip() -> some View {
        self.overlay(
            VStack {
                HStack {
                    HStack {
                        Text("⚠️ ") + Text("ALERT_WORK_IN_PROGRESS")
                        
                    }
                    .padding(.vertical, .layer1)
                    .padding(.horizontal, .layer2)
                    .background(Color.tertiaryBackground.cornerRadius(8))
                    Spacer()
                }
                Spacer()
            }
                .padding(.layer4)
                .allowsHitTesting(false)
            
        )
    }
}
