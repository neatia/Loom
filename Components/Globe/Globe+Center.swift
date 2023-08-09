import Granite
import SwiftUI

extension Globe {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var socialViewOptions: Int = 0
            var accountModuleSize: CGFloat = 126
            var columns: Int = 0
            var tab: Tab = .accounts
        }
        
        @Store public var state: State
    }
    
    enum Tab: GraniteModel {
        case accounts
        case explorer
    }
}
