//
//  GraniteScrollView+Mac.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//
#if os(macOS)
import Foundation
import AppKit

import SwiftUI

struct NSScrollViewWrapper<Content: View>: NSViewRepresentable {
    let content: () -> Content
    
    @Binding var shouldUpdate: Bool
    @State var offset: CGPoint = .zero
    
    //let contentView: NSHostingView<Content>
    init(_ shouldUpdate: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content) {
        self._shouldUpdate = shouldUpdate
        self.content = content
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        context.coordinator.make()
        
        let contentView = context.coordinator.containerView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let clipView = NSClipView()
        clipView.documentView = contentView
        clipView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.contentView = clipView
        
        context.coordinator.constraints = [contentView.topAnchor.constraint(equalTo: clipView.topAnchor),
        contentView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor)]
        
        let constraints = [
            clipView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            clipView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            clipView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            clipView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints + context.coordinator.constraints)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard shouldUpdate else {
            return
        }
        
        shouldUpdate = false
        
        let stackView = context.coordinator.stackView
        
        let contentView = NSHostingView(rootView: content())
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(contentView)
        
        let constraints = [
            contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    class Coordinator {
        //A container in case for added views in the hierarchy
        let containerView: NSView = .init()
        let stackView: NSStackView = .init()
        
        var constraints: [NSLayoutConstraint] = []
        
        func make() {
            containerView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.orientation = .vertical
            stackView.spacing = 0
            
            let constraints = [
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]
            
            NSLayoutConstraint.activate(constraints)
        }
    }
}
class SafeClipView: NSClipView {
    var safeDocumentView: NSView? {
        didSet {
            if oldValue !== safeDocumentView {
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.duration = 0
                    self.documentView = nil
                }, completionHandler: { [weak self] in
                    self?.documentView = self?.safeDocumentView
                })
            }
        }
    }
}
#endif
