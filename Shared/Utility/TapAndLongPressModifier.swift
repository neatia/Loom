//
//  TapAndLongPressModifier.swift
//  * stoic
//
//  Created by PEXAVC on 1/29/21.
//

import Foundation
import SwiftUI

public struct TapAndLongPressModifier: ViewModifier {
    @State private var isLongPressing = false
    let tapAction: (()->())
    let longPressAction: (()->())?
    
    public init(tapAction: @escaping (()->()),
                longPressAction: (()->())? = nil) {
        self.tapAction = tapAction
        self.longPressAction = longPressAction
    }
    
    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .scaleEffect(isLongPressing ? 0.95 : 1.0)
            .simultaneousGesture(LongPressGesture(minimumDuration: 1.0).onChanged({ isPressing in
                withAnimation {
                    isLongPressing = isPressing
                }
            }).onEnded { value in
                withAnimation {
                    isLongPressing = false
                }
                
                longPressAction?()
            })
            .highPriorityGesture(
                TapGesture().onEnded {
                tapAction()
            })
    }
}
