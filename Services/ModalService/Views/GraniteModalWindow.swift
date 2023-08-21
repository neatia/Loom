#if os(iOS)

import UIKit
import SwiftUI

class GraniteModalWindow : UIWindow {
    
    struct PassthroughView : UIViewRepresentable {
        typealias UIViewType = Self.View
        
        class View : UIView {
            
            override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
                return nil
            }
            
        }
        
        func makeUIView(context: Context) -> View {
            let view = Self.View()
            return view
        }
        
        func updateUIView(_ uiView: View, context: Context) {
            //Nothing to do
        }
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == rootViewController?.view.subviews.first {
            return nil
        }
        
        return view
    }
    
}

#else

import AppKit
import SwiftUI

class GraniteModalWindow : NSWindow {
    
    struct PassthroughView : NSViewRepresentable {
        typealias NSViewType = Self.View
        
        class View : NSView {
            override func hitTest(_ point: NSPoint) -> NSView? {
                return nil
            }
        }
        
        func makeNSView(context: Context) -> View {
            let view = Self.View()
            
            return view
        }
        
        func updateNSView(_ nsView: View, context: Context) {
            //Nothing to do
        }
    }
}

#endif
