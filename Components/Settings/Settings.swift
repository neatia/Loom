import Granite
import SwiftUI

struct Settings: GraniteComponent {
    @Command var center: Center
    
    @Environment(\.openURL) var openURL
    
    @State var action = WebViewAction.idle
    @State var webState = WebViewState.empty
    
    @Relay var modal: ModalService
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
//    var listeners: Void {
//        account
//            .center
//            .update
//            .listen { value in
//                if let meta = value as? StandardNotificationMeta {
//                    modal.dismissSheet()
//                    modal.presentModal(GraniteToastView(meta))
//                }
//            }
//    }
}
