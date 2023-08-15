import Granite
import SwiftUI
import LemmyKit

extension LayoutService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
            
            #if os(macOS)
            var style: Style = .expanded
            #elseif os(iOS)
            var style: Style = .unknown
            #endif
            
            var feedContext: FeedContext = .idle {
                didSet {
                    switch feedContext {
                    case .viewPost:
                        self.closeFeedDisplayView = false
                    default:
                        break
                    }
                }
            }
            
            var feedCommunityContext: FeedCommunityContext = .idle
            var closeFeedDisplayView: Bool = true {
                didSet {
                    LayoutService.expandWindow(close: closeFeedDisplayView)
                }
            }
        }
        
        @Store(persist: "persistence.Loom.layout.0000",
               autoSave: true,
               preload: true) public var state: State
    }
    
    enum Style: GraniteModel {
        case compact
        case expanded
        case unknown
    }
    
    enum FeedContext: GraniteModel, Hashable {
        case viewPost(PostView)
        case idle
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .viewPost(let model):
                hasher.combine(model.id)
            default:
                hasher.combine("\(self)")
            }
        }
    }
    
    enum FeedCommunityContext: GraniteModel {
        case viewCommunityView(CommunityView)
        case viewCommunity(Community)
        case idle
    }
    
    static func expandWindow(close: Bool = false) {
        #if os(macOS)
        if close {
            GraniteNavigationWindow.shared.updateWidth(720, id: "main")
        } else {
            GraniteNavigationWindow.shared.updateWidth(1200, id: "main")
        }
        #endif
    }
    
    static var style: Style = .unknown
}
