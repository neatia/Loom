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
    func sideMenuIf<MenuContent: View>(
        _ condition: Bool,
        isShowing: Binding<Bool>,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) -> some View {
        Group {
            if condition {
                self.modifier(SideMenu(isShowing: isShowing, menuContent: menuContent))
            } else {
                self
            }
        }
    }
}

public struct SideMenu<MenuContent: View>: ViewModifier {
    @Binding var isShowing: Bool
    
    var startLocationThreshold: CGFloat = 0.1
    var startThreshold: CGFloat = 0.05
    var activeThreshold: CGFloat = 0.5
    var viewingThreshold: CGFloat = 0.7
    
    var startLocationWidth: CGFloat
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
        self.startLocationWidth = viewingWidth * startLocationThreshold
        self.menuContent = menuContent
    }
    
    public func body(content: Content) -> some View {
        let drag = DragGesture()
            .onChanged { value in
                if isShowing {
                    guard abs(value.translation.width) >= startWidth else {
                        return
                    }
                } else {
                    guard abs(value.startLocation.x) <= startLocationWidth else {
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    let translation = (value.translation.width - (startWidth * (isShowing ? -1 : 1))) + (isShowing ? width : 0)
                    self.offsetX = max(0, min(translation, width))
                }
            }
            .onEnded { event in
                DispatchQueue.main.async {
                    if offsetX > activeThreshold * width {
                        self.isShowing = true
                    } else{
                        self.isShowing = false
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
        }
        .gesture(drag)
        .onChange(of: isShowing) { value in
            withAnimation {
                self.offsetX = value ? width : 0
            }
        }
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
