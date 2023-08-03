import Foundation
import SwiftUI

public struct GraniteScrollViewStyle {
    
    public var tintColor : Color
    
    public var threshold : CGFloat
    public var progressOffset : CGFloat
    public var fetchMoreOffset : CGFloat

    public init(tintColor : Color = .white,
                threshold : CGFloat = 50,
                progressOffset : CGFloat = 35,
                fetchMoreOffset : CGFloat = 35) {
        self.tintColor = tintColor
        self.threshold = threshold
        self.progressOffset = progressOffset
        self.fetchMoreOffset = fetchMoreOffset
    }
    
}

private struct GraniteScrollViewStyleKey : EnvironmentKey {
    
    static let defaultValue: GraniteScrollViewStyle = GraniteScrollViewStyle()
    
}

extension EnvironmentValues {
    
    public var GraniteScrollViewStyle : GraniteScrollViewStyle {
        get { self[GraniteScrollViewStyleKey.self] }
        set { self[GraniteScrollViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func GraniteScrollViewStyle(_ style : GraniteScrollViewStyle) -> some View {
        self.environment(\.GraniteScrollViewStyle, style)
    }
    
}
