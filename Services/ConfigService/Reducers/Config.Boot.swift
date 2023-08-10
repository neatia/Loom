import Granite
import LemmyKit
import IPFSKit

extension ConfigService {
    struct Boot: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        @Relay var layout: LayoutService
        
        func reduce(state: inout Center.State) async {
            LemmyKit.baseUrl = state.config.baseUrl
            ConfigService.configureIPFS(state.ipfsGatewayUrl)
            
            account.center.boot.send()
            content.center.boot.send()
            
            layout.preload()
            
            if layout.state.style == .unknown {
                if Device.isExpandedLayout {
                    layout._state.style.wrappedValue = .expanded
                } else {
                    layout._state.style.wrappedValue = .compact
                }
            }
            
            if layout.state.style == .expanded {
                LayoutService.expandWindow(close: layout.state.closeFeedDisplayView)
            }
            
            //Services.all.explorer.preload()
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
    
    struct Restart: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            var accountMeta: AccountMeta?
            var host: String?
        }
        
        @Payload var meta: Meta?
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        
        func reduce(state: inout Center.State) async {
            guard let meta else { return }
            
            if let host = meta.host {
                LemmyKit.baseUrl = host
                state.config = .init(baseUrl: host)
            } else if let accountMeta = meta.accountMeta {
                LemmyKit.baseUrl = accountMeta.host
                state.config = .init(baseUrl: accountMeta.host)
                
                LoomLog("booting account")
                account.center.boot.send(AccountService.Boot.Meta(accountMeta: accountMeta))
            }
                
            guard meta.host != nil || meta.accountMeta != nil else { return }
            
            let host: String = (meta.host ?? meta.accountMeta?.host) ?? ""
            
            content.center.boot.send()
            
            if meta.accountMeta == nil {
                broadcast.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(host)", event: .normal))
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
