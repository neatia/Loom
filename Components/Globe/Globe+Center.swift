import Granite
import SwiftUI

extension Globe {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var socialViewOptions: Int = 0
            var accountModuleSize: CGFloat = 126
            var columns: Int = 0
        }
        
        @Store public var state: State
    }
}
