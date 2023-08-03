//
//  Passthrough.swift
//  * stoic (iOS)
//
//  Created by PEXAVC on 1/6/21.
//

import Foundation
import SwiftUI

struct Passthrough<Content>: View where Content: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
    }
}

struct GraniteVGrid<Content>: View where Content: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
    }
}
