import Granite
import SwiftUI
import Foundation

extension Home {
    struct DidAppear: GraniteReducer {
        typealias Center = Home.Center
        
        
        func reduce(state: inout Center.State) {
            state.hasAppeared = true
        }
    }
}
