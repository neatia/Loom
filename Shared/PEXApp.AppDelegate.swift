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
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme,
           scheme.caseInsensitiveCompare("nycLoom://") == .orderedSame,
           let page = url.host {
            
            let userDefault = UserDefaults(suiteName: "group.nyc.loom")
        }
        print(url)
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
        
        Granite.App.Lifecycle.didFinishLaunching.post()
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) {
           [weak self] event in
            Granite.App.Interaction.windowClickedOutside.post()
       }
        
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .rightMouseDown]) {
            [weak self] event in
            
            if GraniteNavigationWindow.shared.containsWindow(event.windowNumber) {
                Granite.App.Interaction.windowClickedInside.post()
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
