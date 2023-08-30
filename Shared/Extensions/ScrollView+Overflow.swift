//
//  ScrollView+Overflow.swift
//  Loom
//
//  Created by PEXAVC on 7/27/23.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool,
                             axis: Axis.Set = .horizontal) -> some View {
        if condition {
            ScrollView([axis], showsIndicators: false) {
                self
            }
            //TODO: customizable
            .frame(minHeight: axis.contains(.vertical) ? 300 : nil)
        } else {
            self
        }
    }
}

extension View {
    func scrollOnOverflow(axis: Axis.Set = .horizontal) -> some View {
        modifier(OverflowContentViewModifier(axisSet: axis))
    }
    func scrollOnOverflowIf(_ condition: Bool, axis: Axis.Set = .horizontal) -> some View {
        Group {
            if condition {
                self.modifier(OverflowContentViewModifier(axisSet: axis))
            } else {
                self
            }
        }
    }
}

struct OverflowContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    
    var axisSet: Axis.Set
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
            .background(
                GeometryReader { contentGeometry in
                    Color.clear.onAppear {
                        if axisSet.contains(.horizontal) {
                            contentOverflow = contentGeometry.size.width > geometry.size.width
                            
                        }
                        
                        if axisSet.contains(.vertical) {
                            contentOverflow = contentGeometry.size.height > geometry.size.height || contentOverflow
                        }
                    }
                }
            )
            .wrappedInScrollView(when: contentOverflow, axis: axisSet)
        }
    }
}
