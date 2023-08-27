//
//  AdaptsToKeyboard.swift
//  Loom
//
//  Created by PEXAVC on 7/23/23.
//

import Foundation
import SwiftUI
import Combine

#if os(iOS)
struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    var safeAreaAware: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.currentHeight + (safeAreaAware ? UIApplication.shared.windowSafeAreaInsets.bottom : 0))
                .onAppear(perform: {
                    NotificationCenter
                        .Publisher(center: NotificationCenter.default,
                                   name: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter
                            .Publisher(center: NotificationCenter.default,
                                       name: UIResponder.keyboardWillChangeFrameNotification))
                        .compactMap { notification in
                            withAnimation(.easeOut(duration: 0.16)) {
                                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                            }
                    }
                    .map { rect in
                        return (rect.height - geometry.safeAreaInsets.bottom) - (safeAreaAware ? UIApplication.shared.windowSafeAreaInsets.bottom : 0)
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                    
                    NotificationCenter
                        .Publisher(center: NotificationCenter.default,
                                   name: UIResponder.keyboardWillHideNotification)
                        .compactMap { notification in
                            return CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}

extension View {
    func adaptsToKeyboard(safeAreaAware: Bool = false) -> some View {
        return modifier(AdaptsToKeyboard(safeAreaAware: safeAreaAware))
    }
    func adaptsToKeyboardIf(_ condition: Bool) -> some View {
        Group {
            if condition {
                modifier(AdaptsToKeyboard())
            } else {
                self
            }
        }
    }
}
#else

extension View {
    func adaptsToKeyboard() -> some View {
        return self
    }
}
#endif
