import Granite
import SwiftUI

extension Globe {
    struct Center: GraniteCenter {
        struct State: GraniteState {
        }
        
        @Store public var state: State
    }
}
