//
//  DebugComponent.swift
//  Loom
//
//  Created by PEXAVC on 8/9/23.
//

import Foundation
import Granite
import SwiftUI

//Used for tracking memory allocs of relays in normal views

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
