import Granite

import IPFSKit

extension ConfigService {
    struct Update: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Payload var meta: AccountModifyMeta?
        
        func reduce(state: inout Center.State) async {
            guard let meta else { return }
            state.showNSFW = meta.showNSFW
            state.showScores = meta.showScores
            state.showBotAccounts = meta.showBotAccounts
            state.sortType = meta.sortType ?? state.sortType
            state.listingType = meta.listingType ?? state.listingType
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
