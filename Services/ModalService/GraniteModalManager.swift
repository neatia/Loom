import Foundation
import SwiftUI
import Granite
import Combine

final public class GraniteModalManager : ObservableObject, GraniteWindowDelegate, GraniteActionable {
    @GraniteAction<Void> var dismissPerfmored
    
    @Published var presenters = [AnyGraniteModal]()
    @Published var sheet : AnyView? = nil
    
    #if os(iOS)
    fileprivate var window : GraniteModalWindow? = nil
    #else
    fileprivate var window : AppWindow? = nil
    #endif
    
    public var view: AnyView? = nil
    
    let sheetManager = GraniteSheetManager()
    
    internal var cancellables: Set<AnyCancellable> = .init()
    
    public init(_ wrapper : @escaping ((GraniteModalContainerView) -> AnyView) = { view in AnyView(view) }) {
        
#if os(iOS)
        DispatchQueue.main.async {
            self.attachWindow(wrapper)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
#else
        DispatchQueue.main.async {
            self.attachWindow(wrapper)
        }
#endif
    }
    
    public func present(_ modal : AnyGraniteModal) {
        DispatchQueue.main.async { [weak self] in
#if os(iOS)
            withAnimation {
                self?.presenters.append(modal)
                self?.window?.isUserInteractionEnabled = true
            }
#else
            self?.centerWindow()
            withAnimation {
                self?.presenters = [modal]
            }
#endif
        }
    }
    
    public func dismiss() {
        guard presenters.count > 0 else {
            #if os(iOS)
            window?.isUserInteractionEnabled = sheetManager.hasContent
            #endif
            return
        }
        
#if os(iOS)
        withAnimation {
            _ = presenters.removeLast()
            
            if presenters.count == 0,
               !sheetManager.hasContent {
                window?.isUserInteractionEnabled = false
            }
        }
#else
        _ = presenters.removeLast()
        dismissPerfmored.perform()
#endif
    }
    
    public func didCloseWindow(_ id: String) {
        
    }
    
    public func destroy() {
        self.window = nil
        sheetManager.destroy()
    }
    
    public func enableWindow() {
        DispatchQueue.main.async { [weak self] in
            #if os(iOS)
            self?.window?.isUserInteractionEnabled = true
            #endif
        }
    }
    
    public func disableWindow() {
        guard presenters.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            #if os(iOS)
            self?.window?.isUserInteractionEnabled = false
            #endif
        }
    }
}

extension GraniteModalManager {
    
    fileprivate func attachWindow(_ wrapper : @escaping ((GraniteModalContainerView) -> AnyView)) {
        
        let rootView = wrapper(GraniteModalContainerView())
            .environmentObject(self)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GraniteModalWindow.PassthroughView())
        
#if os(iOS)
        guard window == nil else {
            return
        }
        
        //Add Alert View
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first as? UIWindowScene else {
            return
        }
        
        let window = GraniteModalWindow(windowScene: windowScene)
        window.windowLevel = .alert
        
        let alertController = UIHostingController(rootView: rootView
            .transformEnvironment(\.graniteAlertViewStyle) { value in
                value = .init()
            }
            .addGraniteSheet(sheetManager,
                             background: Color.clear))
        window.rootViewController = alertController
        //can get initialized on sheet call
        window.isUserInteractionEnabled = sheetManager.hasContent
        window.backgroundColor = UIColor.clear
        window.rootViewController?.view.backgroundColor = .clear
        
        self.window = window
        
        window.makeKeyAndVisible()
#else
        
        let sheetView = GraniteModalWindow.PassthroughView()
            .addGraniteSheet(sheetManager,
                             background: Color.clear)
        
        guard let keyWindow = GraniteNavigationWindow.shared.mainWindow?.retrieve() else {
            return
        }
        
        //Add normal alert modal
        let frame = keyWindow.frame
        let window = AppWindow(.child(size: frame.size))
        window.contentViewController = NSHostingController(rootView: rootView
            .frame(width: 600))
        
        window.backgroundColor = .clear
        window.contentViewController?.view.layer?.backgroundColor = .clear
        
        let centerTop: CGPoint = .init(frame.origin.x + frame.size.width / 2, frame.size.height + keyWindow.titlebarHeight)
        
        
        window.setFrame(.init(origin: .init(centerTop.x - (window.frame.size.width / 2),
                                            centerTop.y),
                              size: frame.size),
                        display: true)
        keyWindow.addChildWindow(window, ordered: .above)
        
        //Add sheetView
        let controller = NSHostingController(rootView: sheetView)
        
        keyWindow.contentViewController?.addChild(controller)
        
        guard let contentView = keyWindow.contentView else {
            return
        }
        self.window = window
        
        contentView.addSubview(controller.view)
#endif
    }
    
    func centerWindow() {
        #if os(macOS)
        guard let keyWindow = GraniteNavigationWindow.shared.mainWindow?.retrieve() else {
            return
        }
//        let frame = keyWindow.frame
//        let centerTop: CGPoint = .init(frame.origin.x + frame.size.width / 2, frame.size.height + keyWindow.titlebarHeight)
//        let windowWidth = window?.frame.size.width ?? 0
//        self.window?.setFrame(.init(origin: .init(centerTop.x - (windowWidth / 2),
//                                            centerTop.y),
//                              size: frame.size),
//                        display: true)
        self.window?.setCenter(.init(keyWindow.frame.midX, keyWindow.frame.midY))
        #endif
    }
}
