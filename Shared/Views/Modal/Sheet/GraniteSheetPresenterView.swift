#if os(iOS)

import Foundation
import SwiftUI
import UIKit
import Combine

fileprivate struct GraniteSheetPresenterView : UIViewControllerRepresentable {
    
    let shouldPreventDismissal : Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.parent?.isModalInPresentation = shouldPreventDismissal == true
        }
    }
    
}


fileprivate struct GraniteFullScreenCoverView<Content : View> : UIViewRepresentable {
    
    fileprivate class Coordinator {
        
        let controller : UIHostingController<Content>
        
        init(content : Content) {
            self.controller = UIHostingController(rootView: content)
            controller.modalPresentationStyle = .fullScreen
        }
        
        func present() {
            guard controller.isBeingPresented == false else {
                return
            }
            
            UIApplication.shared.topViewController?.present(controller, animated: true, completion: nil)
        }
        
        func dismiss() {
            guard controller.isBeingPresented == true else {
                return
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    let isPresented : Bool
    let content : Content
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        view.alpha = 0.0
        view.frame = .zero
        view.isUserInteractionEnabled = false
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isPresented == true {
            context.coordinator.present()
        }
        else {
            context.coordinator.dismiss()
        }
        
        context.coordinator.controller.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content)
    }
    
}

fileprivate struct GranitePartialSheetView<Content : View> : UIViewRepresentable {
    
    fileprivate class Coordinator {
        
        let controller: UIHostingController<Content>
        
        init(content : Content) {
            
            let controller = UIHostingController(rootView: content)
            self.controller = controller
        }
        
        func present() {
            guard controller.isBeingPresented == false else {
                return
            }
            
            UIApplication.shared.topViewController?.present(controller, animated: true, completion: nil)
        }
        
        func dismiss() {
            guard controller.isBeingPresented == true else {
                return
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    let isPresented : Bool
    let content : Content
    
    func makeUIView(context: Context) -> some UIView {
//        let view = UIView()
//
//        view.alpha = 0.0
//        view.frame = .zero
        //view.isUserInteractionEnabled = false
        
        return context.coordinator.controller.view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isPresented == true {
            context.coordinator.present()
        }
        else {
            context.coordinator.dismiss()
        }
        
        context.coordinator.controller.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content)
    }
    
}

extension View {
    
    func graniteSheetDismissable(shouldPreventDismissal : Bool) -> some View {
        self
            .background(GraniteSheetPresenterView(shouldPreventDismissal: shouldPreventDismissal))
    }
    
    func graniteFullScreenCover<Content : View>(isPresented : Binding<Bool>, @ViewBuilder content : () -> Content) -> some View {
        self
            .background(GraniteFullScreenCoverView(isPresented: isPresented.wrappedValue, content: content()))
    }
    
    func graniteSheetCover<Content : View>(isPresented : Binding<Bool>, @ViewBuilder content : () -> Content) -> some View {
        self
            .background(GranitePartialSheetView(isPresented: isPresented.wrappedValue, content: content()))
    }
}

#endif
