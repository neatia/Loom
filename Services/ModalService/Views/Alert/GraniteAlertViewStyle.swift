import Foundation
import SwiftUI

public struct GraniteAlertViewStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var actionColor : Color
    public var destructiveColor : Color
    public var overlayColor : Color
    
    public var alertVerticalPadding : CGFloat
    public var alertHorizontalPadding : CGFloat
    public var alertOuterHorizontalPadding : CGFloat
    
    public var sheetVerticalSpacing : CGFloat
    public var sheetHorizontalPadding : CGFloat
    public var sheetVerticalPadding : CGFloat
    
    public init(backgroundColor : Color = Color.black,
                foregroundColor : Color = Color.foreground,
                actionColor : Color = .blue,
                destructiveColor : Color = .red,
                overlayColor : Color = Color.black.opacity(0.5),
                verticalPadding : CGFloat = 15,
                horizontalPadding : CGFloat = 15,
                outerHorizontalPadding : CGFloat = 40,
                sheetVerticalSpacing : CGFloat = 15,
                sheetHorizontalPadding : CGFloat = 15,
                sheetVerticalPadding : CGFloat = 0) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.actionColor = actionColor
        self.destructiveColor = destructiveColor
        self.overlayColor = overlayColor
        self.alertVerticalPadding = verticalPadding
        self.alertHorizontalPadding = horizontalPadding
        self.alertOuterHorizontalPadding = outerHorizontalPadding
        self.sheetVerticalSpacing = sheetVerticalSpacing
        self.sheetHorizontalPadding = sheetHorizontalPadding
        self.sheetVerticalPadding = sheetVerticalPadding
    }
    
}

private struct GraniteAlertViewStyleKey : EnvironmentKey {
    
    static let defaultValue: GraniteAlertViewStyle = GraniteAlertViewStyle()
    
}

extension EnvironmentValues {
    
    public var graniteAlertViewStyle : GraniteAlertViewStyle {
        get { self[GraniteAlertViewStyleKey.self] }
        set { self[GraniteAlertViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func graniteAlertViewStyle(_ style : GraniteAlertViewStyle) -> some View {
        self.environment(\.graniteAlertViewStyle, style)
    }
    
}
