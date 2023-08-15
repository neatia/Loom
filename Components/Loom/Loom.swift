import Granite
import SwiftUI
import LemmyKit

struct Loom: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: LoomService
    
    let communityView: CommunityView?
    
    init(communityView: CommunityView? = nil) {
        self.communityView = communityView
        service.preload()
    }
}
