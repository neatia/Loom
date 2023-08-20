//
//  View+Size.swift
//  Loom
//
//  Created by PEXAVC on 8/19/23.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct MeasureSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self,
                                   value: geometry.frame(in: .global))
        })
    }
}

extension View {
    func measureSize(perform action: @escaping (CGRect) -> Void) -> some View {
        self.modifier(MeasureSizeModifier())
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
    
    func measureSizeIf(_ condition: Bool, perform action: @escaping (CGRect) -> Void) -> some View {
        Group {
            if condition {
                self.modifier(MeasureSizeModifier())
                    .onPreferenceChange(SizePreferenceKey.self, perform: action)
            } else {
                self
            }
        }
    }
}
