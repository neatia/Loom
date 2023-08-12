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
            var showNSFW: Bool = false
            var showScores: Bool = false
            var showBotAccounts: Bool = false
            var sortType: SortType = .hot
            var listingType: ListingType = .all
        }
        
        @Event var boot: Boot.Reducer
        @Event(debounce: 0.25) var restart: Restart.Reducer
        @Event(debounce: 0.25) var update: Update.Reducer
        
        @Store(persist: "persistence.config.Loom.0018", autoSave: true, preload: true) public var state: State
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

