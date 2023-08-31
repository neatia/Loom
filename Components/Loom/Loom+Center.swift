import Granite
import SwiftUI
import FederationKit

extension Loom {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var viewOption: ViewOption = .looms
        }
        
        @Store public var state: State
    }
    
    enum DisplayKind: GraniteModel {
        case compact
        case expanded
    }
    
    enum Intent: GraniteModel {
        case adding(FederatedCommunityResource)
        case edit(LoomManifest)
        case creating
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
    
    enum ViewOption: GraniteModel {
        case looms
        case communities
    }
}
