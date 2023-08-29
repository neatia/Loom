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
            var index: Int = 0
        }
        
        @Event(debounce: 0.5) var debounce: DebounceInterval.Reducer
        @Event var normal: DebounceInterval.Reducer
        
        @Store var state: State
    }
    
    @State var toggle: Bool = false
    
    var view: some View {
        VStack {
            if toggle {
                //PostCardView(model: .mock)
            }
            
            Text("\(state.index)")

            Button {
                center.normal.send()
            } label: {
                Text("Increment")
            }
            .buttonStyle(.plain)
            
            Button {
                center.debounce.send()
            } label: {
                Text("Increment Debounce")
            }
            .buttonStyle(.plain)
//            PostCardView(model: .mock)
        }
    }
}

struct DebounceInterval: GraniteReducer {
    typealias Center = DebugComponent.Center
    func reduce(state: inout Center.State) {
        state.index += 1
    }
    
//    var behavior: GraniteReducerBehavior {
//        .task(.userInitiated)
//    }
}
