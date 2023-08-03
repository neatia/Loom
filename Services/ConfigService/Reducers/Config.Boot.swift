import Granite
import LemmyKit
import IPFSKit

extension ConfigService {
    struct Boot: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        
        func reduce(state: inout Center.State) {
            LemmyKit.baseUrl = state.config.baseUrl
            ConfigService.configureIPFS(state.ipfsGatewayUrl)
            
            account.center.boot.send()
            content.center.boot.send()
            
            if state.style == .unknown || state.style == .expanded {
                #if os(macOS)
                ConfigService.expandWindow(close: state.closeFeedDisplayView)
                #endif
            }
        }
    }
    
    struct Restart: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            var accountMeta: AccountMeta
        }
        
        @Payload var meta: Meta?
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
            LemmyKit.baseUrl = meta.accountMeta.host
            
            state.config = .init(baseUrl: meta.accountMeta.host)
            
            account.center.boot.send(AccountService.Boot.Meta(accountMeta: meta.accountMeta))
            content.center.boot.send()
            //TODO: probably re-login flow here
        }
    }
}
