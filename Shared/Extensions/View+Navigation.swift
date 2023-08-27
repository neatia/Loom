//
//  View+Navigation.swift
//  Loom
//
//  Created by PEXAVC on 8/22/23.
//

import Foundation
import SwiftUI

extension View {
    func wrapInNavigationView() -> some View {
        #if os(iOS)
        NavigationView {
            self
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        #else
        self
        #endif
    }
}
