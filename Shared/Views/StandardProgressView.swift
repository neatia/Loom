//
//  ProgressView.swift
//  Loom
//
//  Created by PEXAVC on 9/1/23.
//

import Foundation
import SwiftUI

struct StandardProgressView: View {
    var body: some View {
        #if os(iOS)
        ProgressView()
        #else
        ProgressView()
            .scaleEffect(0.6)
        #endif
    }
}
