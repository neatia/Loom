import Foundation
import Granite
import SwiftUI
import GraniteUI
import SafariServices

public protocol ModalMeta: GranitePayload {
    var title: LocalizedStringKey { get set }
    var message: LocalizedStringKey { get set }
    var event: GraniteToastViewEvent { get set }
    
}
public struct StandardErrorMeta: ModalMeta {
    public var title: LocalizedStringKey
    public var message: LocalizedStringKey
    public var event: GraniteToastViewEvent
}
public struct StandardNotificationMeta: ModalMeta {
    public var title: LocalizedStringKey
    public var message: LocalizedStringKey
    public var event: GraniteToastViewEvent
}

struct ModalService : GraniteService {
    @Service var center: Center
    
    static var shared: ModalService = .init()
    
    static var alertViewStyle: GraniteAlertViewStyle {
        GraniteAlertViewStyle(backgroundColor: Color.background,
                              foregroundColor: Color.foreground,
                              actionColor: Color.foreground,
                              overlayColor: Color.red,
                              sheetVerticalPadding: 15)
    }
    
    static var toastStyle: GraniteToastViewStyle {
        GraniteToastViewStyle(backgroundColor: Color.alternateBackground.opacity(0.95),
                              foregroundColor: Color.foreground)
    }
    
    let modalManager = GraniteModalManager { view in
        AnyView(
            view
                .graniteAlertViewStyle(ModalService.alertViewStyle)
                .graniteToastViewStyle(ModalService.toastStyle)
        )
    }
    
    //toasts within sheets
//    let modalSheetManager = GraniteModalManager { view in
//        AnyView(
//            view
//                .graniteAlertViewStyle(ModalService.alertViewStyle)
//                .graniteToastViewStyle(ModalService.toastStyle)
//        )
//    }
    
    var sheetManager: GraniteSheetManager {
        modalManager.sheetManager
    }
}

#if os(iOS)
extension UIApplication {
    
    var topViewController : UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        guard window.isUserInteractionEnabled == true else {
                            continue
                        }
                        
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        
        return topViewController
    }
    
}
#endif

extension ModalService {
    
    func dismissAll() {
        modalManager.dismiss()
    }
    
}
