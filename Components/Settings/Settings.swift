import Granite
import SwiftUI

struct Settings: GraniteComponent {
    @Command var center: Center
    
    @Environment(\.openURL) var openURL
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var listeners: Void {
        account
            .center
            .update
            .listen(.broadcast("settings")) { value in
                if let meta = value as? AccountService.Update.ResponseMeta {
                    ModalService.shared.dismissSheet()
                    ModalService.shared.presentModal(GraniteToastView(meta.notification))
                }
            }
    }
    
}
