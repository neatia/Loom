#if os(iOS)
import SwiftUI

/// Defines the modal presentation style of the `View`.
@available(iOS 15, *)
public enum ModalPresentationStyle {
    /// The default presentation style chosen by the system.
    case automatic
    /// A presentation style that partially covers the underlying content.
    ///
    /// - Parameters:
    ///   - properties: properties to assign to `UISheetPresentationController`
    case pageSheet(properties: SheetProperties? = nil)
    /// A presentation style that displays the content centered in the screen.
    ///
    /// - Parameters:
    ///   - properties: properties to assign to `UISheetPresentationController`
    case formSheet(properties: SheetProperties? = nil)
    /// A view presentation style in which the presented view covers the screen.
    case overFullScreen
    /// A presentation style where the content is displayed over another view controller’s content.
    case overCurrentContext
    /// A presentation style where the content is displayed in a popover view.
    /// - Parameters:
    ///   - permittedArrowDirections: The arrow directions that you allow for the popover.
    ///   - sourceRectTransform: allows to change the `sourceRect` of the `UIPopoverPresentationController`
    ///   - adaptiveSheetProperties: properties to assign to adaptive `UISheetPresentationController` which will be used when the app's scene is resized into `.compact` horizontal size class (via multitasking).
    case popover(permittedArrowDirections: UIPopoverArrowDirection = .any, sourceRectTransform: ((CGRect) -> CGRect)? = nil, adaptiveSheetProperties: SheetProperties? = nil)
    /// A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
    case custom(transitioningDelegate: UIViewControllerTransitioningDelegate?)
}

protocol ModalPresentationConfigurator {
    func setup(_ viewController: UIViewController, presenter: UIViewController, isInitial: Bool)
}

extension ModalPresentationConfigurator {
    static func setupModalPresentationStyle(_ viewController: UIViewController, style: UIModalPresentationStyle, isInitial: Bool) {
        if isInitial {
            viewController.modalPresentationStyle = style
        }
    }

    static func setupCustom(_ viewController: UIViewController, transitioningDelegate: UIViewControllerTransitioningDelegate?, isInitial: Bool) {
        setupModalPresentationStyle(viewController, style: .custom, isInitial: isInitial)
        viewController.transitioningDelegate = transitioningDelegate
    }

    static func setupPageSheet(_ viewController: UIViewController, presenter: UIViewController, isInitial: Bool) {
        setupModalPresentationStyle(viewController, style: .pageSheet, isInitial: isInitial)
    }

    static func setupFormSheet(_ viewController: UIViewController, presenter: UIViewController, isInitial: Bool) {
        setupModalPresentationStyle(viewController, style: .formSheet, isInitial: isInitial)
    }

    static func setupPopover(_ viewController: UIViewController,
                             presenter: UIViewController,
                             sourceRectTransform: ((CGRect) -> CGRect)?,
                             permittedArrowDirections: UIPopoverArrowDirection,
                             isInitial: Bool) {
        setupModalPresentationStyle(viewController, style: .popover, isInitial: isInitial)
        if isInitial {
            viewController.popoverPresentationController?.sourceView = presenter.view
            let sourceRect = sourceRectTransform?(presenter.view.bounds) ?? presenter.view.bounds
            viewController.popoverPresentationController?.sourceRect = sourceRect
            viewController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        }
    }
}

protocol SheetPropertiesPresentationConfigurator: ModalPresentationConfigurator {
    var selectedDetentIdentifierBinding: Binding<UISheetPresentationController.Detent.Identifier?>? { get }
}

extension SheetPropertiesPresentationConfigurator {
    static func setupPageSheet(_ viewController: UIViewController, presenter: UIViewController, properties: SheetProperties?, isInitial: Bool) {
        setupPageSheet(viewController, presenter: presenter, isInitial: isInitial)
        setup(viewController.sheetPresentationController, presenter: presenter, properties: properties, isInitial: isInitial)
    }

    static func setupFormSheet(_ viewController: UIViewController, presenter: UIViewController, properties: SheetProperties?, isInitial: Bool) {
        setupFormSheet(viewController, presenter: presenter, isInitial: isInitial)
        setup(viewController.sheetPresentationController, presenter: presenter, properties: properties, isInitial: isInitial)
    }

    static func setupPopover(_ viewController: UIViewController,
                             presenter: UIViewController,
                             sourceRectTransform: ((CGRect) -> CGRect)?,
                             permittedArrowDirections: UIPopoverArrowDirection,
                             adaptiveSheetProperties: SheetProperties?,
                             isInitial: Bool) {
        setupModalPresentationStyle(viewController, style: .popover, isInitial: isInitial)
        if isInitial {
            viewController.popoverPresentationController?.sourceView = presenter.view
            let sourceRect = sourceRectTransform?(presenter.view.bounds) ?? presenter.view.bounds
            viewController.popoverPresentationController?.sourceRect = sourceRect
            viewController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        }
        setup(viewController.popoverPresentationController?.adaptiveSheetPresentationController, presenter: presenter, properties: adaptiveSheetProperties, isInitial: isInitial)
    }

    static func setup(_ sheetPresentationController: UISheetPresentationController?, presenter: UIViewController, properties: SheetProperties?, isInitial: Bool) {
        guard let sheetPresentationController = sheetPresentationController,
              let properties = properties
        else { return }

        if sheetPresentationController.prefersEdgeAttachedInCompactHeight != properties.prefersEdgeAttachedInCompactHeight {
            sheetPresentationController.prefersEdgeAttachedInCompactHeight = properties.prefersEdgeAttachedInCompactHeight
        }

        if sheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached != properties.widthFollowsPreferredContentSizeWhenEdgeAttached {
            sheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = properties.widthFollowsPreferredContentSizeWhenEdgeAttached
        }

        if sheetPresentationController.prefersGrabberVisible != properties.prefersGrabberVisible {
            sheetPresentationController.prefersGrabberVisible = properties.prefersGrabberVisible
        }

        if sheetPresentationController.preferredCornerRadius != properties.preferredCornerRadius {
            sheetPresentationController.preferredCornerRadius = properties.preferredCornerRadius
        }

        let sorted = properties.detents.sorted()
        if !sheetPresentationController.detents.elementsEqual(sorted) {
            sheetPresentationController.detents = sorted
        }

        if let binding = properties.selectedDetentIdentifier,
           sheetPresentationController.selectedDetentIdentifier != binding.wrappedValue {
            let setter = {
                sheetPresentationController.selectedDetentIdentifier = binding.wrappedValue
            }
            if !isInitial, properties.animatesSelectedDetentIdentifierChange {
                sheetPresentationController.animateChanges(setter)
            } else {
                setter()
            }
        }

        if sheetPresentationController.largestUndimmedDetentIdentifier != properties.largestUndimmedDetentIdentifier {
            sheetPresentationController.largestUndimmedDetentIdentifier = properties.largestUndimmedDetentIdentifier
        }

        if sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge != properties.prefersScrollingExpandsWhenScrolledToEdge {
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = properties.prefersScrollingExpandsWhenScrolledToEdge
        }

        if isInitial {
            sheetPresentationController.sourceView = properties.shouldAdjustToSourceView ? presenter.view : nil
        }
    }
}

extension UISheetPresentationController.Detent: Comparable {
    public static func < (lhs: UISheetPresentationController.Detent, rhs: UISheetPresentationController.Detent) -> Bool {
        lhs == medium() && rhs == large() ? true : false
    }
}

extension ModalPresentationStyle: SheetPropertiesPresentationConfigurator {
    internal var selectedDetentIdentifierBinding: Binding<UISheetPresentationController.Detent.Identifier?>? {
        switch self {
        case .pageSheet(let properties): return properties?.selectedDetentIdentifier
        case .formSheet(let properties): return properties?.selectedDetentIdentifier
        case .popover(_, _, let adaptiveSheetProperties): return adaptiveSheetProperties?.selectedDetentIdentifier
        default: return nil
        }
    }

    internal func setup(_ viewController: UIViewController, presenter: UIViewController, isInitial: Bool) {
        switch self {
        case .automatic:
            Self.setupModalPresentationStyle(viewController, style: .automatic, isInitial: isInitial)
        case .pageSheet(let properties):
            Self.setupPageSheet(viewController, presenter: presenter, properties: properties, isInitial: isInitial)
        case .formSheet(let properties):
            Self.setupFormSheet(viewController, presenter: presenter, properties: properties, isInitial: isInitial)
        case .overFullScreen:
            Self.setupModalPresentationStyle(viewController, style: .overFullScreen, isInitial: isInitial)
        case .overCurrentContext:
            Self.setupModalPresentationStyle(viewController, style: .overCurrentContext, isInitial: isInitial)
        case .popover(let permittedArrowDirections, let sourceRectTransform, let adaptiveSheetProperties):
            Self.setupPopover(viewController,
                              presenter: presenter,
                              sourceRectTransform: sourceRectTransform,
                              permittedArrowDirections: permittedArrowDirections,
                              adaptiveSheetProperties: adaptiveSheetProperties,
                              isInitial: isInitial)
        case .custom(let transitioningDelegate):
            Self.setupCustom(viewController, transitioningDelegate: transitioningDelegate, isInitial: isInitial)
        }
    }
}
#endif
