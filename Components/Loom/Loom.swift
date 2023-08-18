import Granite
import SwiftUI
import LemmyKit

struct Loom: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: LoomService
    @Relay var modal: ModalService
    
    let communityView: CommunityView?
    
    var listeners: Void {
        service
            .center
            .modify
            .listen(.beam) { value in
                if let response = value as? StandardErrorMeta {
                    modal.presentModal(GraniteToastView(response))
                }
            }
    }
    
    init(communityView: CommunityView? = nil) {
        self.communityView = communityView
        service.preload()
    }
}
