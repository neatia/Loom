import Granite
import SwiftUI

extension Settings {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var oldKeywordsFilter: String = ""
            var keywordsFilter: String = ""
        }
        
        @Store public var state: State
    }
}
