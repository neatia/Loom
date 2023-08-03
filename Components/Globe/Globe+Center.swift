import Granite
import SwiftUI

extension Globe {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var socialViewOptions: Int = 0
            var accountModuleSize: CGFloat = 126
        }
        
        @Store public var state: State
    }
}
