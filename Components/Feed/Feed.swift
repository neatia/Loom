import Granite
import SwiftUI
import Combine
import FederationKit

struct Feed: GraniteComponent {
    @Command var center: Center
    
    @Relay var config: ConfigService
    @Relay var content: ContentService
    @Relay var account: AccountService
    @Relay var loom: LoomService
    
    @Environment(\.graniteNavigationStyle) var navigationStyle
    @Environment(\.graniteRouter) var router
    
    /*
     Note: there is no "LayoutService" in the top level.
     Avoid redraws, as for Expanded layout manages 3 different
     component states.
     
     Instead use a reducer to reset with the relay initialized within
     */
    
    @StoreObject(String(reflecting: Self.self)) var pager: Pager<FederatedPostResource>
    
    let isCommunity: Bool
    
    init(_ community: FederatedCommunity? = nil,
         federatedData: FederatedData? = nil) {
        
        self.isCommunity = community != nil
        if let community {
            _pager = .init("\(community.id)_feed")
        }
        
        let location: FederatedLocationType?
        
        if let federatedData, federatedData.host != FederationKit.host {
            location = .peer(federatedData.host)
        } else {
            location = nil
        }
        
        _center = .init(.init(community: community,
                              location: location ?? .base,
                              peerLocation: location))
        
        content.preload()
    }
}
