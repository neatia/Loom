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
            .listen(.broadcast) { value in
                if let meta = value as? StandardNotificationMeta {
                    modal.presentModal(GraniteToastView(meta))
                }
            }
        
        config
            .center
            .restart
            .listen(.broadcast) { value in
                if let meta = value as? StandardNotificationMeta {
                    modal.presentModal(GraniteToastView(meta))
                }
            }
    }
    
    init() {
        #if os(iOS)
        let width = ContainerConfig.iPhoneScreenWidth
        //3 cells with layer4 padding in between
        let moduleWith = (width / 3) - (.layer4 * 2)
        _center = .init(.init(accountModuleSize: moduleWith))
        #endif
    }
}
