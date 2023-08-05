import Granite
import SwiftUI
import LemmyKit
import IPFSKit

extension ConfigService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var config: InstanceConfig = .default
            
            //Feed
            var linkPreviewMetaData: Bool = false
            
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
                    ConfigService.expandWindow(close: closeFeedDisplayView)
                }
            }
            
            //Write
            var enableIPFS: Bool = false {
                didSet {
                    guard enableIPFS else { return }
                    if isIPFSAvailable {
                        ConfigService.configureIPFS(ipfsGatewayUrl)
                    }
                }
            }
            var ipfsGatewayUrl: String = "https://gateway.ipfs.io"
            var isIPFSAvailable: Bool = false
            
            //Account
            var showNSFW: Bool = false
            var showScores: Bool = false
            var showBotAccounts: Bool = false
            var sortType: SortType = .hot
            var listingType: ListingType = .all
        }
        
        @Event var boot: Boot.Reducer
        @Event var restart: Restart.Reducer
        @Event var update: Update.Reducer
        
        @Store(persist: "persistence.config.Lemur.0015", autoSave: true) public var state: State
    }
    
    struct Preferences {
        static var pageLimit: Int = 30
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
    
    static func configureIPFS(_ gatewayUrl: String) {
        if let ipfsKey = try? AccountService.getToken(identifier: AccountService.keychainIPFSKeyToken, service: AccountService.keychainService),
           let ipfsSecret = try? AccountService.getToken(identifier: AccountService.keychainIPFSSecretToken, service: AccountService.keychainService) {
            
            IPFSKit.gateway = InfuraGateway(ipfsKey, secret: ipfsSecret, gateway: gatewayUrl)
        }
    }
}

