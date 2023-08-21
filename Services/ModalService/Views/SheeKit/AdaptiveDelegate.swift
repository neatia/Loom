#if os(iOS)
import SwiftUI

class AdaptiveDelegate<Item>: NSObject, UIPopoverPresentationControllerDelegate where Item : Identifiable {
    var performNextPresentationIfNeeded: (() -> Void)?
    var dismissedByUserCallback: DismissAction?
    var isInteractiveDismissDisabled = false
    var nextPresentation: (() -> Void)?
    weak var sheetHost: SheetHostingController<Item>?

    override init() {
        super.init()
        performNextPresentationIfNeeded = { [weak self] in
            guard let nextPresentation = self?.nextPresentation else { return }
            self?.nextPresentation = nil
            nextPresentation()
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissedByUserCallback?()
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !isInteractiveDismissDisabled
    }
}

final class AdaptiveSheetDelegate<Item>: AdaptiveDelegate<Item>, UISheetPresentationControllerDelegate where Item : Identifiable {

    var selectedDetentIdentifierBinding: Binding<UISheetPresentationController.Detent.Identifier?>?

    override init() { super.init() }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        selectedDetentIdentifierBinding?.wrappedValue = sheetPresentationController.selectedDetentIdentifier
    }
}
#endif
