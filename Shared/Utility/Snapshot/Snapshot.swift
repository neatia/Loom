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
        
        let controller = UIHostingController(rootView: content())
        let view = controller.view
        
        return view ?? .init()
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        guard isScreenshotting else { return }
        isScreenshotting = false
        
        let renderer = UIGraphicsImageRenderer(size: uiView.frame.size)

        let image = renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
        
        if let encodeMessage {
            let result = MarqueKit.shared.encode(encodeMessage, withImage: image)
            ModalService
                .share(image: result.data)
            
            print(MarqueKit.shared.decode(image: result.data).payload)
        } else {
            ModalService
                .share(image: image)
        }
        
    }
    #else
    public func makeNSView(context: Content) -> NSView {
        
        //TODO:
        
        return .init()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        //TODO: 
    }
    #endif
}
