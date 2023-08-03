#if os(iOS)
import Foundation
import UIKit

extension UIApplication {
    var windowSafeAreaInsets: UIEdgeInsets {
        windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
}
#endif
