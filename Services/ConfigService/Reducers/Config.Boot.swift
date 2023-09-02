import Granite
import IPFSKit
import FederationKit

extension ConfigService {
    struct Boot: GraniteReducer {
        typealias Center = ConfigService.Center
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        @Relay var layout: LayoutService
        @Relay var loom: LoomService
        
        func reduce(state: inout Center.State) async {
            FederationKit.initialize(state.server)
            ConfigService.configureIPFS(state.ipfsGatewayUrl)
            
            account.restore(wait: true)
            account.center.boot.send()
            
            content.restore(wait: true)
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
            loom.restore(wait: true)
            loom._state.intent.wrappedValue = .idle
            loom._state.display.wrappedValue = .compact
            loom._state.activeManifest.wrappedValue = nil
            
            //Pager Filter
            //TODO: a reducer meant for all content filteration needs. This could site in ContentService
            PagerFilter.enableForNSFW = state.showNSFW == false
            PagerFilter.enableForBots = state.showBotAccounts == false
            PagerFilter.enableForNSFWExtended = state.extendedNSFWFilterEnabled
            PagerFilter.enableForKeywords = state.keywordsFilterEnabled
            
            PagerConfig.manuallyFetchMoreContent = state.manuallyFetchMoreContent
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
