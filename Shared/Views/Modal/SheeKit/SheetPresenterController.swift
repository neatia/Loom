#if os(iOS)
import SwiftUI

final class SheetPresenterController: UIViewController {
    private final class AppearanceCallbackView: UIView {
        override class var layerClass: AnyClass { CATransformLayer.self }
        var onAppearCallback: (() -> Void)?
        override func didMoveToWindow() {
            if window != nil {
                onAppearCallback?()
                onAppearCallback = nil
            }
        }
        
        @MainActor
        func scheduleOnAppear(_ closure: @escaping () -> Void) {
            if window != nil {
                closure()
            } else {
                onAppearCallback = closure
            }
        }
        
        @MainActor
        func cancelSheduledOnAppear() {
            onAppearCallback = nil
        }
    }

    weak var presenterProxy: UIViewController?

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        /// Fix of https://github.com/edudnyk/SheeKit/issues/8 - the NavigationView considers sheet presenter
        /// as a displayable detail controller of navigation controller / split controller.
        if parent is UINavigationController || parent is UITabBarController || parent is UISplitViewController || parent is UIPageViewController {
            presenterProxy = parent
            willMove(toParent: nil)
            removeFromParent()
        } else if parent != nil {
            presenterProxy = self
        } else {
            guard parent == nil,
                  let proxy = presenterProxy,
                  proxy != self,
                  proxy.isViewLoaded, isViewLoaded,
                  view.isDescendant(of: proxy.view)
            else {
                presenterProxy = nil
                return
            }
        }
    }
    
    override func loadView() {
        view = AppearanceCallbackView()
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @MainActor
    func scheduleOnAppear(_ closure: @escaping () -> Void) {
        guard let appearanceCallbackView = view as? AppearanceCallbackView else { return }
        appearanceCallbackView.scheduleOnAppear(closure)
    }
    
    @MainActor
    func cancelSheduledOnAppear() {
        guard isViewLoaded, let appearanceCallbackView = view as? AppearanceCallbackView else { return }
        appearanceCallbackView.cancelSheduledOnAppear()
    }
}

private extension UIView {
    var nextResponderViewController: UIViewController? {
        guard let next = next as? UIViewController else {
            if let next = next as? UIView {
                return next.nextResponderViewController
            } else {
                return nil
            }
        }
        return next
    }
}

struct SheetPresenterControllerRepresentable<Item>: UIViewControllerRepresentable where Item : Identifiable {
    @Binding var item: Item?
    let onDismiss: (() -> Void)?
    let sheetHostProvider: (AdaptiveDelegate<Item>, UIViewController, Item, DismissAction) -> SheetHostingController<Item>
    let sheetHostUpdater: (AdaptiveDelegate<Item>, UIViewController, Bool, DismissAction) -> Void
    
    func makeCoordinator() -> AdaptiveDelegate<Item> {
        if #available(iOS 15, *) {
            return AdaptiveSheetDelegate()
        } else {
            return .init()
        }
    }

    func makeUIViewController(context: Context) -> SheetPresenterController { .init() }

    func updateUIViewController(_ presenter: SheetPresenterController, context: Context) {
        let coordinator = context.coordinator
        let DismissAction = DismissAction(coordinator)
        coordinator.dismissedByUserCallback = DismissAction
        let isCurrentItemSheet = updateSheet(presenter, context: context)
        if let sheetHost = coordinator.sheetHost,
           sheetHost.itemId != nil,
           let presentingViewController = sheetHost.presentingViewController,
           !isCurrentItemSheet {
            sheetHost.itemId = nil
            presentingViewController.dismiss(animated: true, completion: coordinator.performNextPresentationIfNeeded)
            onDismiss?()
        }
        if item != nil,
           !isCurrentItemSheet {
            presenter.scheduleOnAppear { [weak coordinator, weak presenter] in
                guard let item = item,
                      let coordinator = coordinator,
                      coordinator.sheetHost?.itemId != item.id,
                      let presenter = presenter else { return }
                if presenter.parent == nil,
                   let superview = presenter.view.superview,
                   let parent = superview.nextResponderViewController,
                   presenter.view.isDescendant(of: parent.view)
                {
                    parent.addChild(presenter)
                    presenter.didMove(toParent: parent)
                }
                let worker = { [weak coordinator, weak presenter] in
                    guard let coordinator = coordinator,
                          let presenter = presenter,
                          let item = self.item,
                          coordinator.sheetHost?.itemId == nil
                    else { return }
                    let sheetHost = sheetHostProvider(coordinator, presenter, item, DismissAction)
                    sheetHost.onDismiss = onDismiss
                    sheetHost.presentationController?.delegate = coordinator
                    presenter.presenterProxy?.present(sheetHost, animated: true)
                }
                if let previousSheetHost = coordinator.sheetHost,
                   previousSheetHost.itemId == nil,
                   previousSheetHost.presentingViewController != nil {
                    coordinator.nextPresentation = worker
                } else {
                    coordinator.nextPresentation = nil
                    worker()
                }
            }
        } else if item == nil {
            presenter.cancelSheduledOnAppear()
        }
    }
    
    func updateSheet(_ presenter: SheetPresenterController, context: Context) -> Bool {
        guard let sheetHost = context.coordinator.sheetHost,
              sheetHost.presentingViewController != nil else { return false }
        let isCurrentItemSheet = item != nil && sheetHost.itemId == item?.id
        if isCurrentItemSheet, let item = item {
            sheetHost.item = item
            sheetHost.onDismiss = onDismiss
        }
        sheetHostUpdater(context.coordinator, presenter, isCurrentItemSheet, DismissAction(context.coordinator))
        return isCurrentItemSheet
    }
    
    static func dismantleUIViewController(_ presenter: SheetPresenterController, coordinator: AdaptiveDelegate<Item>) {
        if let sheetHost = coordinator.sheetHost,
           let presentingViewController = sheetHost.presentingViewController,
           sheetHost.itemId != nil {
            sheetHost.itemId = nil
            presentingViewController.dismiss(animated: true)
            sheetHost.onDismiss?()
        }

        presenter.cancelSheduledOnAppear()
        coordinator.nextPresentation = nil
        coordinator.sheetHost = nil

        if presenter.parent != nil {
            presenter.willMove(toParent: nil)
            if presenter.isViewLoaded {
                presenter.view.removeFromSuperview()
            }
            presenter.removeFromParent()
        } else if presenter.isViewLoaded {
            presenter.view.removeFromSuperview()
        }
    }
    
    func DismissAction(_ coordinator: AdaptiveDelegate<Item>) -> DismissAction {
        let currentItemId = item?.id
        return .init { [weak coordinator] in
            guard let coordinator = coordinator,
                  let currentItemId = currentItemId,
                  coordinator.sheetHost?.itemId == currentItemId else { return }
            self.item = nil
            if coordinator.sheetHost?.presentingViewController == nil {
                /// Dismissal transition already ended,
                /// ``sheetHost`` has been dismissed by the user via interactive dismiss
                coordinator.sheetHost?.itemId = nil
                onDismiss?()
            }
        }
    }
}
#endif
