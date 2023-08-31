import Granite
import SwiftUI
import FederationKit

extension AccountService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var meta: AccountMeta? = nil
            var profiles: [AccountMeta] = []
            
            //This may not be necessary anymore
            var addToProfiles: Bool = false
            
            var authenticated: Bool = false
        }
        
        @Event var boot: Boot.Reducer
        @Event(debounce: 0.5) var auth: Auth.Reducer
        @Event(debounce: 0.5) var addProfile: AddProfile.Reducer
        @Event var logout: Logout.Reducer
        @Event(debounce: 0.25) var update: Update.Reducer
        @Event(debounce: 0.5) var interact: Interact.Reducer
        
        @Store(persist: "persistence.Loom.account.0007",
               autoSave: true,
               preload: true) public var state: State
    }
    
    var blockedUsers: [PersonRelationshipModel] {
        state.meta?.resource.person_blocks ?? []
    }
    
    var blockedCommunities: [CommunityRelationshipModel] {
        state.meta?.resource.community_blocks ?? []
    }
    
    var hasBlocked: Bool {
        blockedUsers.isNotEmpty || blockedCommunities.isNotEmpty
    }
    
    var isLoggedIn: Bool {
        state.meta != nil
    }
}
