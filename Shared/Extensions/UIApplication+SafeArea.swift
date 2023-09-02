#if os(iOS)
import Foundation
import UIKit

extension UIApplication {
    var windowSafeAreaInsets: UIEdgeInsets {
        windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
    
    func hideKeyboard() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func hideKeyboard() {
        shared.hideKeyboard()
    }
}
#else
import SwiftUI
class UIApplication {
    static let shared: UIApplication = .init()
    
    
    var windowSafeAreaInsets: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    
    func hideKeyboard() {
        
    }
    
    static func hideKeyboard() {
        shared.hideKeyboard()
    }
}

#endif
