//
//  ScrollView+Overflow.swift
//  Lemur
//
//  Created by PEXAVC on 7/27/23.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool) -> some View {
        if condition {
            ScrollView(.horizontal, showsIndicators: false) {
                self
            }
        } else {
            self
        }
    }
}

extension View {
    func scrollOnOverflow() -> some View {
        modifier(OverflowContentViewModifier())
    }
}

struct OverflowContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
            .background(
                GeometryReader { contentGeometry in
                    Color.clear.onAppear {
                        contentOverflow = contentGeometry.size.width > geometry.size.width
                    }
                }
            )
            .wrappedInScrollView(when: contentOverflow)
        }
    }
}
