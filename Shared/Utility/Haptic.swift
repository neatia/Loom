//
//  Haptic.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension View {
    func addHaptic() -> some View {
        self.simultaneousGesture(TapGesture().onEnded {
            GraniteHaptic.light.invoke()
        })
    }
}
