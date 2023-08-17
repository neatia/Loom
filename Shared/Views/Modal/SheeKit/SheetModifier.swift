#if os(iOS)
import SwiftUI

struct SheetModifier<Item, SheetContent>: ViewModifier where Item : Identifiable, SheetContent : View {
    @Binding var item: Item?
    let presentationStyle: ModalPresentationConfigurator
    let presentedViewControllerParameters: UIViewControllerProxy?
    let onDismiss: (() -> Void)?
    @ViewBuilder
    let content: (Item) -> SheetContent
    @State var proxy = UIViewControllerProxy()
    
    func body(content: Content) -> some View {
        content.overlay(SheetPresenterControllerRepresentable(item: $item,
                                                              onDismiss: onDismiss,
                                                              sheetHostProvider: sheetHostProvider,
                                                              sheetHostUpdater: sheetHostUpdater).opacity(0).accessibility(hidden: true))
    }
    
    private var sheetHostProvider: (AdaptiveDelegate<Item>, UIViewController, Item, DismissAction) -> SheetHostingController<Item> { { coordinator, presenter, item, dismiss in
        let rootView = sheetContent(for: item, isPresented: true, dismiss: dismiss) { [weak coordinator] isInteractiveDismissDisabled in
            coordinator?.isInteractiveDismissDisabled = isInteractiveDismissDisabled
        }
        let sheetHost = SheetHostingController(rootView: rootView, item: item)
        presentationStyle.setup(sheetHost, presenter: presenter, isInitial: true)
        sheetHost.configure(by: presentedViewControllerParameters)
        coordinator.sheetHost = sheetHost
        if #available(iOS 15, *),
            let presentationStyle = presentationStyle as? SheetPropertiesPresentationConfigurator,
            let adaptiveSheetDelegate = coordinator as? AdaptiveSheetDelegate {
            adaptiveSheetDelegate.selectedDetentIdentifierBinding = presentationStyle.selectedDetentIdentifierBinding
        }
        return sheetHost
    } }
    
    private var sheetHostUpdater: (AdaptiveDelegate<Item>, UIViewController, Bool, DismissAction) -> Void { { coordinator, presenter, isPresented, dismiss in
        guard let sheetHost = coordinator.sheetHost else { return }
        if isPresented {
            sheetHost.rootView = sheetContent(for: sheetHost.item, isPresented: isPresented, dismiss: dismiss) { [weak coordinator] isInteractiveDismissDisabled in
                coordinator?.isInteractiveDismissDisabled = isInteractiveDismissDisabled
            }
            presentationStyle.setup(sheetHost, presenter: presenter, isInitial: false)
            sheetHost.configure(by: presentedViewControllerParameters)
            if #available(iOS 15, *),
                let presentationStyle = presentationStyle as? SheetPropertiesPresentationConfigurator,
                let adaptiveSheetDelegate = coordinator as? AdaptiveSheetDelegate {
                adaptiveSheetDelegate.selectedDetentIdentifierBinding = presentationStyle.selectedDetentIdentifierBinding
            }
        }
    } }
    
    private func sheetContent(for item: Item, isPresented: Bool, dismiss: DismissAction, onInteractiveDismissDisabled: @escaping (Bool) -> Void) -> AnyView {
        AnyView(
            content(item)
                .environment(\.shee_isPresented, isPresented)
                .environment(\.shee_dismiss, dismiss)
                .onPreferenceChange(SheeInteractiveDismissDisabledPreferenceKey.self, perform: onInteractiveDismissDisabled)
            )
    }
}
#endif
