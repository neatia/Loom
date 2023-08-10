//
//  DebugComponent.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/9/23.
//

import Foundation
import Granite
import SwiftUI

struct DebugComponent: GraniteComponent {
    @Command var center: Center
    
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
        }
        
        @Store var state: State
    }
    
    @State var toggle: Bool = false
    
    var view: some View {
        VStack {
            if toggle {
                PostCardView(model: .mock)
            }

            Button {
                toggle.toggle()
            } label: {
                Text("Test")
            }
            .buttonStyle(.plain)
//            PostCardView(model: .mock)
        }
    }
}
