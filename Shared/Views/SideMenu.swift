//
//  SideMenu.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import SwiftUI

public extension View {
    func sideMenu<MenuContent: View>(
        isShowing: Binding<Bool>,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) -> some View {
        self.modifier(SideMenu(isShowing: isShowing, menuContent: menuContent))
    }
}

public struct SideMenu<MenuContent: View>: ViewModifier {
    @Binding var isShowing: Bool
    
    var startThreshold: CGFloat = 0.05
    var activeThreshold: CGFloat = 0.6
    var viewingThreshold: CGFloat = 0.8
    
    var startWidth: CGFloat
    var width: CGFloat
    
    @State var offsetX: CGFloat = 0
    
    var opacity: CGFloat {
        (offsetX / width) * 0.8
    }
    
    private let menuContent: () -> MenuContent
    
    public init(isShowing: Binding<Bool>,
                @ViewBuilder menuContent: @escaping () -> MenuContent) {
        _isShowing = isShowing
        #if os(iOS)
        let viewingWidth: CGFloat = UIScreen.main.bounds.width * viewingThreshold
        #else
        let viewingWidth: CGFloat = ContainerConfig.iPhoneScreenWidth
        #endif
        self.width = viewingWidth
        self.startWidth = viewingWidth * startThreshold
        self.menuContent = menuContent
    }
    
    public func body(content: Content) -> some View {
        let drag = DragGesture()
            .onChanged { value in
                guard abs(value.translation.width) >= startWidth else {
                    return
                }
                DispatchQueue.main.async {
                    let translation = (value.translation.width - (startWidth * (isShowing ? -1 : 1))) + (isShowing ? width : 0)
                    self.offsetX = max(0, min(translation, width))
                }
            }
            .onEnded { event in
                DispatchQueue.main.async {
                    if offsetX > activeThreshold * width {
                        withAnimation {
                            self.isShowing = true
                            self.offsetX = width
                        }
                    } else{
                        
                        withAnimation {
                            self.isShowing = false
                            self.offsetX = 0
                        }
                    }
                }
        }
        
        return ZStack(alignment: .leading) {
            content
                .disabled(isShowing)
                .offset(x: self.offsetX)
                .overlayIf(offsetX > 0,
                           overlay: Color.alternateBackground.opacity(opacity).ignoresSafeArea())
            
            menuContent()
                .frame(width: width)
                .offset(x: self.offsetX - width)
                .opacity(self.offsetX > 0 ? 1.0 : 0)
                .environment(\.sideMenuVisible, isShowing)
                .environment(\.sideMenuMoving, offsetX != 0 || offsetX != width)
        }.gesture(drag)
    }
}

struct SideMenuVisibilityContextKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var sideMenuVisible: Bool {
        get { self[SideMenuVisibilityContextKey.self] }
        set { self[SideMenuVisibilityContextKey.self] = newValue }
    }
}

struct SideMenuMovingContextKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var sideMenuMoving: Bool {
        get { self[SideMenuMovingContextKey.self] }
        set { self[SideMenuMovingContextKey.self] = newValue }
    }
}
