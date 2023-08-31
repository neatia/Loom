import Granite
import SwiftUI
import FederationKit

struct Loom: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: LoomService
    
    let communityView: FederatedCommunityResource?
    
    var listeners: Void {
        service
            .center
            .modify
            .listen(.beam) { value in
                if let response = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(response))
                }
            }
    }
    
    init(communityView: FederatedCommunityResource? = nil) {
        self.communityView = communityView
        service.preload()
    }
}
