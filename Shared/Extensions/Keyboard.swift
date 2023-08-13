//
//  Keyboard.swift
//  Loom
//
//  Created by PEXAVC on 8/10/23.
//

import Foundation
import SwiftUI

extension View {
    func numpad() -> some View {
        #if os(macOS)
        return self
        #else
        return self.keyboardType(.numberPad)
        #endif
    }
    
    func otpContent() -> some View {
        #if os(macOS)
        return self
        #else
        return self
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
        #endif
    }
    
    func correctionDisabled() -> some View {
        #if os(macOS)
        return self
        #else
        return self
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        #endif
    }
}
