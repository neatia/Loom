import Granite
import LemmyKit
import SwiftUI
import Combine

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
    
    @StateObject var pager: Pager<PostView> = .init(emptyText: "EMPTY_STATE_NO_POSTS")
    
    let isCommunity: Bool
    
    init(_ community: Community? = nil, federatedData: FederatedData? = nil) {
        self.isCommunity = community != nil
        
        let location: FetchType?
        
        if let federatedData, federatedData.host != LemmyKit.host {
            location = .peer(federatedData.host)
        } else {
            location = nil
        }
        
        _center = .init(.init(community: community,
                              location: location ?? .base,
                              peerLocation: location))
        
        content.preload()
        content.silence(viewUpdatesOnly: true)
        loom.silence(viewUpdatesOnly: true)
    }
}
