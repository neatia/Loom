import Granite
import SwiftUI

extension Draft {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var newCategoryName: String = ""
            var categoryExists: Bool = false
        }
        
        @Store public var state: State
    }
}
