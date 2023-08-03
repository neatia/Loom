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
            .scaleEffect(isLongPressing ? 0.97 : 1.0)
            .onTapGesture {
                tapAction()
            }
//            .simultaneousGesture(
//                LongPressGesture(minimumDuration: 1.0)
//                    .onChanged { isPressing in
//                        isLongPressing = isPressing
//                    }
//                    .onEnded { item in
//                        
//                    }
//            )
            .onLongPressGesture(minimumDuration: 1.0, pressing: { (isPressing) in
                withAnimation {
                    isLongPressing = isPressing
                }
            }, perform: {
                longPressAction?()
            })
    }
}
