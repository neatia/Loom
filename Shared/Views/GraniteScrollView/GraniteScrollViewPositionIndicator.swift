import Foundation
import SwiftUI

struct GraniteScrollViewPositionIndicator: View {
    
    enum PositionType {
        case fixed, moving
    }
    
    struct Position: Equatable {
        let type: PositionType
        let frame: CGRect
        var y: CGFloat {
            frame.minY
        }
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
                .preference(key: PositionPreferenceKey.self, value: [Position(type: type, frame: proxy.frame(in: .global))])
        }
    }
}
