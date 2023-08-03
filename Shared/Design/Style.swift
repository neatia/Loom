import Foundation
import SwiftUI

struct AppStyle {
    struct Padding {
        static var level1: CGFloat = 16
        static var level2: CGFloat = 12
        static var level3: CGFloat = 8
        static var level4: CGFloat = 4
    }
    
    struct Colors {
        struct Surface {
            static var background: Color {
                .black
            }
            
            static var foreground: Color {
                .white
            }
        }
        
        struct Text {
            static var light: Color {
                .white
            }
            
            static var dark: Color {
                .black
            }
        }
    }
}
