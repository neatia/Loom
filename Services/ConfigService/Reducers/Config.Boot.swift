import Granite
import LemmyKit
import IPFSKit

extension ConfigService {
    struct Boot: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        @Relay var layout: LayoutService
        @Relay var loom: LoomService
        
        func reduce(state: inout Center.State) {
            LemmyKit.baseUrl = state.config.baseUrl
            ConfigService.configureIPFS(state.ipfsGatewayUrl)
            
            account.center.boot.send()
            
            content.preload()
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
            
            //Marbler
            if state.marbleYoutubeLinks {
                MarbleOptions.enableFX = true
                MarbleOptions.fx = state.marbleFX
            }
            
            //Loom
            loom.preload()
            loom._state.intent.wrappedValue = .idle
            loom._state.display.wrappedValue = .compact
        }
    }
}
