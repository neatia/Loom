//
//  Snapshot.swift
//  Loom (macOS)
//
//  Created by PEXAVC on 8/19/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit
import MarqueKit

#if os(iOS)
import UIKit
#else
import AppKit
#endif


public struct ScreenshotView<Content: View> : GenericViewRepresentable {
    
    @Binding var isScreenshotting: Bool
    @State var frame: CGRect = .zero
    var encodeMessage: String?
    var content: () -> Content
    public init(_ isScreenshotting: Binding<Bool>,
                encodeMessage: String? = nil,
                @ViewBuilder content: @escaping () -> Content) {
        self._isScreenshotting = isScreenshotting
        self.encodeMessage = encodeMessage
        self.content = content
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> UIView {
        context.coordinator.controller = SelfSizingHostingController(rootView: AnyView(
            content()
                .ignoresSafeArea()
        ))
        context.coordinator.controller?.view.isUserInteractionEnabled = false
        
        guard let view = context.coordinator.controller?.view else {
            return .init()
        }
        
        view.invalidateIntrinsicContentSize()
        view.layoutIfNeeded()
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        guard isScreenshotting else {
            //context.coordinator.controller?.rootView = content()
            guard let view = context.coordinator.controller?.view else {
                return
            }
            view.layer.cornerRadius = 16
            return
        }
        
        isScreenshotting = false
        
        let renderer = UIGraphicsImageRenderer(size: uiView.frame.size)

        let image = renderer.image { rendererContext in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
            //uiView.layer.render(in: rendererContext.cgContext)
        }
        
        
        if let encodeMessage {
            let result = MarqueKit.shared.encode(encodeMessage, withImage: MarqueImage(named: "logo")!)
            
            guard let image = result.data else {
                guard let url = result.url else {
                    
                    
                    return
                }
                
                
                ModalService.share(urlString: url.absoluteString)
                return
            }
            
            ModalService
                .share(image: image)

//            let payload = MarqueKit.shared.decode(image: result.data).payload
//            print("{TEST} \(payload)")
        } else {
//            ModalService
//                .share(image: image)
        }
        
    }
    #else
    public func makeNSView(context: Context) -> NSView {
        
        context.coordinator.controller = SelfSizingHostingController(rootView: AnyView(
            content()
                .ignoresSafeArea()
        ))
//        context.coordinator.controller?.view.
        
        guard let view = context.coordinator.controller?.view else {
            return .init()
        }
        
        view.invalidateIntrinsicContentSize()
        view.layoutSubtreeIfNeeded()
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        guard isScreenshotting else {
            //context.coordinator.controller?.rootView = content()
            guard let view = context.coordinator.controller?.view else {
                return
            }
            view.layer?.cornerRadius = 16
            return
        }
        
        isScreenshotting = false
        
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: uiView.frame.size)

        let image = renderer.image { rendererContext in
            uiView.layer.render(in: rendererContext.cgContext)
        }
        #else
        guard let image = context.coordinator.controller?.rootView.snapshot() else {
            return
        }
        
        #endif
        
        ModalService
            .share(image: image)
        
        if let encodeMessage {
            
//            ModalService
//                .share(image: image)

//            let payload = MarqueKit.shared.decode(image: result.data).payload
//            print("{TEST} \(payload)")
        } else {
            
        }
    }
    #endif
    
    public func makeCoordinator() -> Coordinator<AnyView> {
        .init()
    }
    
    public class Coordinator<Content: View> {
        var controller: SelfSizingHostingController<Content>?
    }
}

#if os(iOS)
class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.invalidateIntrinsicContentSize()
    }
}
#else
class SelfSizingHostingController<Content>: NSHostingController<Content> where Content: View {

    override func viewDidLayout() {
        super.viewDidLayout()
        self.view.invalidateIntrinsicContentSize()
    }
}

extension View {
    func snapshot() -> NSImage? {
        let controller = NSHostingController(rootView: self)
        let targetSize = controller.view.intrinsicContentSize
        let contentRect = NSRect(origin: .zero, size: targetSize)
        
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = controller.view
        
        guard
            let bitmapRep = controller.view.bitmapImageRepForCachingDisplay(in: contentRect)
        else { return nil }
        
        controller.view.cacheDisplay(in: contentRect, to: bitmapRep)
        let image = NSImage(size: bitmapRep.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}
#endif
