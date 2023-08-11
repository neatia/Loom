import Granite
import SwiftUI

struct Settings: GraniteComponent {
    @Command var center: Center
    
    @Environment(\.openURL) var openURL
    
    @Relay var modal: ModalService
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var listeners: Void {
        account
            .center
            .update
            .listen(.broadcast) { value in
                if let meta = value as? AccountService.Update.ResponseMeta {
                    modal.dismissSheet()
                    modal.presentModal(GraniteToastView(meta.notification))
                }
            }
    }
}
