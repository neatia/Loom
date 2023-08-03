import Foundation
import SwiftUI

struct GraniteScrollViewPositionIndicator: View {
    
    enum PositionType {
        case fixed, moving
    }
    
    struct Position: Equatable {
        let type: PositionType
        let y: CGFloat
    }
    
    struct PositionPreferenceKey: PreferenceKey {
        typealias Value = [Position]
        
        static var defaultValue = [Position]()
        
        static func reduce(value: inout [Position], nextValue: () -> [Position]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    let type: PositionType
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: PositionPreferenceKey.self, value: [Position(type: type, y: proxy.frame(in: .global).minY)])
        }
    }
}
