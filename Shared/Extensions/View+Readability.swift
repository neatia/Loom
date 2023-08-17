//
//  View+TextReadability.swift
//  Loom
//
//  Created by PEXAVC on 8/12/23.
//

import Foundation
import SwiftUI

//TODO: use in Feed as well
extension View {
    func textReadabilityIf(_ condition: Bool) -> some View {
        self
            .padding(.vertical, condition ? .layer1 : 0)
            .padding(.horizontal, condition ? .layer2 : 0)
            .backgroundIf(condition) {
                Color.background.opacity(0.75)
                    .cornerRadius(6)
            }
    }
    
    func readability(cornerRadius: CGFloat = 8) -> some View {
        self
            .padding(.layer3)
            .background(Color.tertiaryBackground)
            .cornerRadius(cornerRadius)
    }
    
    func readabilityAlternate(cornerRadius: CGFloat = 8) -> some View {
        self
            .padding(.layer3)
            .background(Color.alternateBackground)
            .cornerRadius(cornerRadius)
    }
    
    func outline(cornerRadius: CGFloat = 8) -> some View {
        self
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.foreground.opacity(0.3), lineWidth: 1.0))
    }
}