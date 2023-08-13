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
}
