//
//  PEXApp.AppDelegate.swift
//  Stoic
//
//  Created by PEXAVC on 6/4/23.
//

import Foundation
import SwiftUI
import Granite

#if os(iOS)
import UIKit
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UITextView.appearance().backgroundColor = .clear
        
        return true
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        //TODO: Profiles a memory leak, may be a red herring.
        //Without this, delegates such as detecting windows closing
        //will not fire
        NSApplication.shared.delegate = self
        
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("nyc.stoic.Loom.DidFinishLaunching"), object: nil)
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) {
           [weak self] event in
           let nc = NotificationCenter.default
           nc.post(name: Notification.Name("granite.window.ClickedOutside"), object: nil)
           
       }
        
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .rightMouseDown]) {
            [weak self] event in
            
            if GraniteNavigationWindow.shared.containsWindow(event.windowNumber) {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("granite.window.ClickedInside"), object: nil)
            }
            
            return event
        }
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }

    }
}
#endif
