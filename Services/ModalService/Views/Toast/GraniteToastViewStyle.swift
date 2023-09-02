import Foundation
import SwiftUI

public struct GraniteToastViewStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var errorBackgroundColor : Color
    public var successBackgroundColor : Color
    
    public init(backgroundColor : Color = Color.alternateBackground.opacity(0.95),
                foregroundColor : Color = Color.foreground,
                errorBackgroundColor : Color = Color.red.opacity(0.4),
                successBackgroundColor : Color = Color.green.opacity(0.4)) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.errorBackgroundColor = errorBackgroundColor
        self.successBackgroundColor = successBackgroundColor
    }
    
    public func color(for event : GraniteToastViewEvent) -> Color {
        switch event {
        
        case .normal:
            return backgroundColor
            
        case .error:
            return errorBackgroundColor
            
        case .success:
            return successBackgroundColor
            
        }
    }
    
}

private struct GraniteToastViewStyleKey : EnvironmentKey {
    
    static let defaultValue: GraniteToastViewStyle = GraniteToastViewStyle()
    
}

extension EnvironmentValues {
    
    public var GraniteToastViewStyle : GraniteToastViewStyle {
        get { self[GraniteToastViewStyleKey.self] }
        set { self[GraniteToastViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func graniteToastViewStyle(_ style : GraniteToastViewStyle) -> some View {
        self.environment(\.GraniteToastViewStyle, style)
    }
    
}

