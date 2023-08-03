import Granite
import SwiftUI

struct Globe: GraniteComponent {
    @Command var center: Center
    
    @Relay var modal: ModalService
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var listeners: Void {
        account
            .center
            .addProfile
            .listen { value in
                if let meta = value as? StandardErrorMeta {
                    modal.presentModal(GraniteToastView(meta), target: .sheet)
                } else if let meta = value as? StandardNotificationMeta {
                    modal.dismissSheet()
                    modal.presentModal(GraniteToastView(meta))
                }
            }
        
        account
            .center
            .boot
            .listen { value in
                if let meta = value as? StandardNotificationMeta {
                    modal.presentModal(GraniteToastView(meta))
                }
            }
    }
}
