#if os(iOS)
import SwiftUI

final class SheetHostingController<Item>: UIHostingController<AnyView> where Item : Identifiable {
    var itemId: Item.ID?
    var item: Item
    var onDismiss: (() -> Void)?
    var overrideDisablesAutomaticKeyboardDismissal: Bool?
    var overridePreferredStatusBarStyle: UIStatusBarStyle?
    var overridePrefersStatusBarHidden: Bool?
    var overridePreferredStatusBarUpdateAnimation: UIStatusBarAnimation?
    var overridePrefersPointerLocked: Bool?
    var overridePreferredScreenEdgesDeferringSystemGestures: UIRectEdge?
    var overridePrefersHomeIndicatorAutoHidden: Bool?
    
    init(rootView: AnyView, item: Item) {
        self.itemId = item.id
        self.item = item
        super.init(rootView: rootView)
    }
    
    @available(*, unavailable)
    @MainActor
    @objc
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(by proxy: UIViewControllerProxy?) {
        guard let proxy = proxy else { return }
        modalTransitionStyle = proxy.modalTransitionStyle
        modalPresentationCapturesStatusBarAppearance = proxy.modalPresentationCapturesStatusBarAppearance
        overrideDisablesAutomaticKeyboardDismissal = proxy.disablesAutomaticKeyboardDismissal
        preferredContentSize = proxy.preferredContentSize
        isModalInPresentation = proxy.isModalInPresentation
        
        overridePreferredStatusBarStyle = proxy.preferredStatusBarStyle
        overridePrefersStatusBarHidden = proxy.prefersStatusBarHidden
        overridePreferredStatusBarUpdateAnimation = proxy.preferredStatusBarUpdateAnimation
        
        if #available(iOS 14, *), overridePrefersPointerLocked != proxy.prefersPointerLocked {
            overridePrefersPointerLocked = proxy.prefersPointerLocked
            setNeedsUpdateOfPrefersPointerLocked()
        }
        
        overridePrefersHomeIndicatorAutoHidden = proxy.prefersHomeIndicatorAutoHidden
        
        if overridePreferredScreenEdgesDeferringSystemGestures != proxy.preferredScreenEdgesDeferringSystemGestures {
            overridePreferredScreenEdgesDeferringSystemGestures = proxy.preferredScreenEdgesDeferringSystemGestures
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let r = overridePreferredStatusBarStyle else { return super.preferredStatusBarStyle }
        return r
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let r = overridePrefersStatusBarHidden else { return super.prefersStatusBarHidden }
        return r
    }
    
    @available(iOS 14, *)
    override var prefersPointerLocked: Bool {
        guard let r = overridePrefersPointerLocked else { return super.prefersPointerLocked }
        return r
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        guard let r = overridePrefersHomeIndicatorAutoHidden else { return super.prefersHomeIndicatorAutoHidden }
        return r
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        guard let r = overridePreferredScreenEdgesDeferringSystemGestures else { return super.preferredScreenEdgesDeferringSystemGestures }
        return r
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        guard let r = overridePreferredStatusBarUpdateAnimation else { return super.preferredStatusBarUpdateAnimation }
        return r
    }
}
#endif
