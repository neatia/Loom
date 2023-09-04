import Granite
import SwiftUI
import IPFSKit
import MarbleKit
import FederationKit

extension ConfigService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var server: FederationServer = .default
            
            //Feed
            var linkPreviewMetaData: Bool = false
            var feedStyle: FeedStyle = .style2
            var manuallyFetchMoreContent: Bool = false {
                didSet {
                    PagerConfig.manuallyFetchMoreContent = manuallyFetchMoreContent
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
            var ipfsContentType: Int = 0
            
            //Account
            var showNSFW: Bool = false {
                didSet {
                    PagerFilter.enableForNSFW = showNSFW == false
                }
            }
            var showScores: Bool = false
            var showBotAccounts: Bool = false {
                didSet {
                    PagerFilter.enableForBots = showBotAccounts == false
                }
            }
            var sortType: FederatedSortType = .hot
            var listingType: FederatedListingType = .all
            
            //Filter
            var extendedNSFWFilterEnabled: Bool = false {
                didSet {
                    PagerFilter.enableForNSFWExtended = extendedNSFWFilterEnabled
                }
            }
            var keywordsFilter: FilterConfig = .empty
            var keywordsFilterEnabled: Bool = false {
                didSet {
                    PagerFilter.enableForKeywords = keywordsFilterEnabled
                    PagerFilter.filterKeywords = keywordsFilter
                }
            }
            
            //Marble
            var marbleYoutubeLinks: Bool = false {
                didSet {
                    MarbleOptions.enableFX = marbleYoutubeLinks
                }
            }
            var marbleFX: MarbleWebGLCatalog.FX = .granite {
                didSet {
                    MarbleOptions.fx = marbleFX
                }
            }
            var marblePlaybackControls: Bool = false
            
            //Sharing
            var enableWatermark: Bool = true
            
            //Federation
            var allowAutomaticFinding: Bool = true
        }
        
        @Event var boot: Boot.Reducer
        @Event(debounce: 0.25) var restart: Restart.Reducer
        @Event(debounce: 0.25) var update: Update.Reducer
        
        @Store(persist: "persistence.config.Loom.0024", autoSave: true) public var state: State
    }
    
    struct Preferences {
        static var pageLimit: Int = 10
    }
    
    static func configureIPFS(_ gatewayUrl: String) {
        if let ipfsKey = try? AccountService.getToken(identifier: AccountService.keychainIPFSKeyToken, service: AccountService.keychainService),
           let ipfsSecret = try? AccountService.getToken(identifier: AccountService.keychainIPFSSecretToken, service: AccountService.keychainService) {
            
            IPFSKit.gateway = InfuraGateway(ipfsKey, secret: ipfsSecret, gateway: gatewayUrl)
        }
    }
}

