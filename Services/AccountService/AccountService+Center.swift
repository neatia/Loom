import Granite
import SwiftUI
import LemmyKit

extension AccountService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var meta: AccountMeta? = nil
            var profiles: [AccountMeta] = []
            var addToProfiles: Bool = false
            
            
            var authenticated: Bool = false
        }
        
        @Event var boot: Boot.Reducer
        @Event var auth: Auth.Reducer
        @Event var addProfile: AddProfile.Reducer
        @Event var logout: Logout.Reducer
        @Event var update: Update.Reducer
        @Event var interact: Interact.Reducer
        
        @Store(persist: "persistence.Loom.account.0005", autoSave: true, preload: true) public var state: State
    }
    
    var blockedUsers: [PersonBlockView] {
        state.meta?.info.person_blocks ?? []
    }
    
    var blockedCommunities: [CommunityBlockView] {
        state.meta?.info.community_blocks ?? []
    }
    
    var hasBlocked: Bool {
        blockedUsers.isNotEmpty || blockedCommunities.isNotEmpty
    }
    
    var isLoggedIn: Bool {
        state.meta != nil
    }
}
