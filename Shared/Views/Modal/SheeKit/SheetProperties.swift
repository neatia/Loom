#if os(iOS)
import SwiftUI

public struct SheetProperties {
    /// Set to true to cause the sheet to layout with an edge-attached appearance in compact height instead of full screen.
    /// Default: `false`
    public var prefersEdgeAttachedInCompactHeight: Bool

    /// Set to true to allow ``UIViewControllerProxy/preferredContentSize`` to influence the width of the sheet when edge-attached.
    /// When `false`, the width of the sheet when edge-attached is always equal to the safe area width of the container.
    /// The value of this property is not respected in compact width regular height.
    /// Default: `false`
    public var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool

    /// Set to true to show a grabber at the top of the sheet.
    /// Default: `false`
    public var prefersGrabberVisible: Bool

    /// The preferred corner radius of the sheet when presented.
    /// This value is only respected when the sheet is at the front of its stack.
    /// Default: `nil` (uses system default corner radius in this case)
    public var preferredCornerRadius: CGFloat?

    /// The array of detents that the sheet may rest at.
    /// This array must have at least one element.
    /// Detents must be specified in order from smallest to largest height.
    /// Default: an array of only `.large()`
    public var detents: [UISheetPresentationController.Detent]

    /// The identifier of the selected detent. When binding's wrapped value is `nil` or the identifier is not found in detents, the sheet is displayed at the smallest detent.
    /// When binding is `nil` (default), the user's chosen detent is considered unmanaged and is never overwritten.
    /// Default: `nil`
    public var selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>? = nil

    /// Set to `true` to enforce the sheet to animate adaptation to a newly set ``selectedDetentIdentifier`` which is different from the one that has been used previously.
    /// Default: `false`
    public var animatesSelectedDetentIdentifierChange: Bool

    /// The identifier of the largest detent that is not dimmed. When `nil` or the identifier is not found in detents, all detents are dimmed.
    /// Default: `nil`
    public var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?

    /// If there is a larger detent to expand to than the selected detent, and a descendent scroll view is scrolled to top, this controls whether scrolling down will expand to a larger detent.
    /// Useful to set to `false` for non-modal sheets, where scrolling in the sheet should not expand the sheet and obscure the content above.
    /// Default: `true`
    public var prefersScrollingExpandsWhenScrolledToEdge: Bool

    /// Set to `true` so that the sheet will attempt to visually center itself over the `View` which it is attached to.
    /// Default: `false`
    public var shouldAdjustToSourceView: Bool
    
    public init(
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        prefersGrabberVisible: Bool = false,
        preferredCornerRadius: CGFloat? = nil,
        detents: [UISheetPresentationController.Detent] = [ .large() ],
        selectedDetentIdentifier: Binding<UISheetPresentationController.Detent.Identifier?>? = nil,
        animatesSelectedDetentIdentifierChange: Bool = false,
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        shouldAdjustToSourceView: Bool = false
    ) {
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.prefersGrabberVisible = prefersGrabberVisible
        self.preferredCornerRadius = preferredCornerRadius
        self.detents = detents
        self.selectedDetentIdentifier = selectedDetentIdentifier
        self.animatesSelectedDetentIdentifierChange = animatesSelectedDetentIdentifierChange
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.shouldAdjustToSourceView = shouldAdjustToSourceView
    }
}
#endif
