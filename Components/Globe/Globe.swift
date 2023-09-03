import Granite
import SwiftUI

struct Globe: GraniteComponent {
    @Command var center: Center
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var listeners: Void {
        account
            .center
            .addProfile
            .listen(.broadcast("globe")) { value in
                if let meta = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(meta), target: .sheet)
                } else if let meta = value as? StandardNotificationMeta {
                    ModalService.shared.dismissSheet()
                    ModalService.shared.presentModal(GraniteToastView(meta))
                }
            }
        
        account
            .center
            .boot
            .listen(.broadcast("globe")) { value in
                if let meta = value as? StandardNotificationMeta {
                    ModalService.shared.presentModal(GraniteToastView(meta))
                }
            }
        
        config
            .center
            .restart
            .listen(.broadcast("globe")) { value in
                if let meta = value as? StandardNotificationMeta {
                    ModalService.shared.presentModal(GraniteToastView(meta))
                }
            }
    }
}
