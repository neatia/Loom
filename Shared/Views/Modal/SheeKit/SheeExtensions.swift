#if os(iOS)
//https://github.com/edudnyk/SheeKit
import SwiftUI

private struct TrueIdentifiable: Identifiable {
    var id: Bool { true }
}

extension View {
    public func shee<Item, Content>(item: Binding<Item?>,
                                    presentationStyle: ModalPresentationStyle = .automatic,
                                    presentedViewControllerParameters: UIViewControllerProxy? = nil,
                                    onDismiss: (() -> Void)? = nil,
                                    @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : Identifiable, Content : View {
        return self.modifier(SheetModifier(item: item,
                                           presentationStyle: presentationStyle,
                                           presentedViewControllerParameters: presentedViewControllerParameters,
                                           onDismiss: onDismiss,
                                           content: content))
    }
    
    public func shee<Content>(isPresented: Binding<Bool>,
                              presentationStyle: ModalPresentationStyle = .automatic,
                              presentedViewControllerParameters: UIViewControllerProxy? = nil,
                              onDismiss: (() -> Void)? = nil,
                              @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        let itemBinding = Binding<TrueIdentifiable?>(get: { isPresented.wrappedValue ? TrueIdentifiable() : nil }, set: { isPresented.wrappedValue = $0 != nil ? true : false })
        return self.modifier(SheetModifier(item: itemBinding,
                                           presentationStyle: presentationStyle,
                                           presentedViewControllerParameters: presentedViewControllerParameters,
                                           onDismiss: onDismiss) { _ in
            content()
        })
    }
    public func shee_interactiveDismissDisabled(_ isDisabled: Bool = true) -> some View {
        preference(key: SheeInteractiveDismissDisabledPreferenceKey.self, value: isDisabled)
    }
}

public struct DismissAction {
    let closure: () -> Void
    
    internal init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    @available(iOS 15.0, *)
    internal init(_ custom: Self?, system: SwiftUI.DismissAction?) {
        closure = {
            if let custom = custom {
                custom()
            } else {
                system?()
            }
        }
    }

    @available(iOS, deprecated: 15, obsoleted: 15) @_disfavoredOverload
    internal init(_ custom: Self?, system: (() -> Void)?) {
        closure = {
            if let custom = custom {
                custom()
            } else {
                system?()
            }
        }
    }

    public func callAsFunction() { closure() }
}

struct SheeInteractiveDismissDisabledPreferenceKey: PreferenceKey {
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }

    static var defaultValue = false
}

extension EnvironmentValues {
    private struct DismissActionEnvironmentKey: EnvironmentKey {
        static var defaultValue: DismissAction?
    }

    private struct SheeIsPresentedEnvironmentKey: EnvironmentKey {
        static var defaultValue = false
    }

    public internal(set) var shee_dismiss: DismissAction {
        get {
            return DismissAction(self[DismissActionEnvironmentKey.self], system: self[keyPath: \.dismiss])
        }
        set { self[DismissActionEnvironmentKey.self] = newValue }
    }
    
    public internal(set) var shee_isPresented: Bool {
        get {
            if #available(iOS 15, *) {
                return self[SheeIsPresentedEnvironmentKey.self] || self[keyPath: \.isPresented]
            } else {
                return self[SheeIsPresentedEnvironmentKey.self] || self[keyPath: \.presentationMode].wrappedValue.isPresented
            }
        }
        set { self[SheeIsPresentedEnvironmentKey.self] = newValue }
    }
}
#endif
