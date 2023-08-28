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
    
    /*
     Note: there is no "LayoutService" in the top level.
     Avoid redraws, as for Expanded layout manages 3 different
     component states.
     
     Instead use a reducer to reset with the relay initialized within
     */
    
    @StateObject var pager: Pager<PostView> = .init(emptyText: "EMPTY_STATE_NO_POSTS")
    
    let isCommunity: Bool
    
    init(_ community: Community? = nil) {
        self.isCommunity = community != nil
        
        /* Routing logic, this should probably be on the LemmyKit level? */
        if community != nil {
            LoomLog("Feed Starting: \(community?.actor_id.host) from: \(LemmyKit.host)")
        }
        
        let location: FetchType
        if community?.actor_id.host != LemmyKit.host,
           let peerHost = community?.actor_id.host {
            if peerHost == community?.ap_id?.host {
            
                LoomLog("Feed Connected to source")
                location = .source
            } else {
                LoomLog("Feed Connected to peer")
                location = .peer(peerHost)
            }
        } else {
            location = .base
        }
        
        _center = .init(.init(community: community, location: location, peerLocation: community?.location?.isPeer == true ? community?.location : nil))
        
        content.preload()
        content.silence(viewUpdatesOnly: true)
        loom.silence(viewUpdatesOnly: true)
    }
}
