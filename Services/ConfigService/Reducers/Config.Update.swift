import Granite
import LemmyKit
import IPFSKit

extension ConfigService {
    struct Update: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Payload var meta: AccountModifyMeta?
        
        @Relay var account: AccountService
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            state.showNSFW = meta.showNSFW
            state.showScores = meta.showScores
            state.showBotAccounts = meta.showBotAccounts
            state.sortType = meta.sortType ?? state.sortType
            state.listingType = meta.listingType ?? state.listingType
            
            guard account.isLoggedIn else { return }
            account.center.update.send(meta)
        }
    }
}
