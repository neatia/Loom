import Granite
import SwiftUI
import Foundation

extension Home {
    struct SnapCancel: GraniteReducer {
        typealias Center = Home.Center
        
        func reduce(state: inout Center.State) {
            state.status.removeAll()
            state.capturedPhoto = nil
        }
    }
}
