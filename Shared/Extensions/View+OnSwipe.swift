//
//  View+OnSwipe.swift
//  Loom
//
//  Created by PEXAVC on 7/23/23.
//

import Foundation
import SwiftUI

//#if os(iOS)
struct OnSwipe: ViewModifier {
    
    let action: () -> Void
    var edge: HorizontalAlignment = .trailing
    var icon: String = "trash"
    var iconColor: Color = .red
    
    @State var offset: CGSize = .zero
    @State var initialOffset: CGSize = .zero
    @State var contentWidth: CGFloat = 0.0
    @State var willDeleteIfReleased = false
    
    var startThreshold: CGFloat = 32
    
    var directionCoeff: CGFloat {
        switch edge {
        case .trailing:
            return -1
        default:
            return 1
        }
    }
   
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(iconColor)
                        Image(systemName: icon)
                            .foregroundColor(.foreground)
                            .font(.title2.bold())
                            .layoutPriority(-1)
                    }.frame(width: directionCoeff * offset.width)
                    .offset(x: edge == .leading ? -offset.width : geometry.size.width)
                    .onAppear {
                        contentWidth = geometry.size.width
                    }
                    .gesture(
                        TapGesture()
                            .onEnded {
                                trigger()
                            }
                    )
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture (
                DragGesture()
                    .onChanged { gesture in
                        switch edge {
                        case .trailing:
                            guard gesture.location.x > contentWidth / 2,
                                  abs(gesture.location.x - gesture.startLocation.x) > startThreshold else {
                                return
                            }
                            
                            if gesture.translation.width + initialOffset.width <= 0 {
                                self.offset.width = (gesture.translation.width + initialOffset.width) + (initialOffset.width == 0 ? startThreshold : -startThreshold)
                            }
                            if self.offset.width < -deletionDistance && !willDeleteIfReleased {
                                hapticFeedback()
                                willDeleteIfReleased.toggle()
                            } else if offset.width > -deletionDistance && willDeleteIfReleased {
                                hapticFeedback()
                                willDeleteIfReleased.toggle()
                            }
                        default:
                            guard gesture.location.x < contentWidth / 2,
                                  abs(gesture.location.x - gesture.startLocation.x) > startThreshold else {
                                return
                            }
                            if gesture.translation.width + initialOffset.width >= 0 {
                                self.offset.width = (gesture.translation.width + initialOffset.width) + (initialOffset.width == 0 ? -startThreshold : startThreshold)
                            }
                            if self.offset.width > deletionDistance && !willDeleteIfReleased {
                                hapticFeedback()
                                willDeleteIfReleased.toggle()
                            } else if offset.width < deletionDistance && willDeleteIfReleased {
                                hapticFeedback()
                                willDeleteIfReleased.toggle()
                            }
                        }
                    }
                    .onEnded { _ in
                        switch edge {
                        case .trailing:
                            if offset.width < -deletionDistance {
                                trigger()
                            } else if offset.width < -halfDeletionDistance {
                                offset.width = -tappableDeletionWidth
                                initialOffset.width = -tappableDeletionWidth
                            } else {
                                offset = .zero
                                initialOffset = .zero
                            }
                        default:
                            if offset.width > deletionDistance {
                                trigger()
                            } else if offset.width > halfDeletionDistance {
                                offset.width = tappableDeletionWidth
                                initialOffset.width = tappableDeletionWidth
                            } else {
                                offset = .zero
                                initialOffset = .zero
                            }
                        }
                    }
            )
            .animation(.interactiveSpring(), value: offset.width)
    }
    
    private func trigger() {
        //offset.width = -contentWidth
        offset = .zero
        initialOffset = .zero
        action()
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    //MARK: Constants
    
    let deletionDistance = CGFloat(200)
    let halfDeletionDistance = CGFloat(50)
    let tappableDeletionWidth = CGFloat(100)
}

extension View {
    
    func onSwipe(edge: HorizontalAlignment = .trailing,
                 icon: String = "trash",
                 iconColor: Color = .red,
                 backgroundColor: Color = .background,
                 disabled: Bool = false,
                 perform action: @escaping () -> Void) -> some View {
        Group {
            if disabled {
                self
            } else {
                self
                    .background(backgroundColor)
                    .modifier(OnSwipe(action: action, edge: edge, icon: icon, iconColor: iconColor))
            }
        }
    }
}
