import Granite
import SwiftUI
import LemmyKit

extension Loom {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var display: DisplayKind = .compact
            var isCreating: Bool = false
        }
        
        @Store public var state: State
    }
    
    enum DisplayKind: GraniteModel {
        case compact
        case expanded
    }
    
    enum Intent: GraniteModel {
        case adding(CommunityView)
        case idle
        
        var isAdding: Bool {
            switch self {
            case .adding:
                return true
            default:
                return false
            }
        }
    }
}
