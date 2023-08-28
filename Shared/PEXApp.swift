//
//  PEXApp.swift
//  Shared
//
//  Created by PEXAVC on 7/18/22.
//

import SwiftUI
import Granite

@main
struct PEXApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var config: ConfigService = .init()
    
    
    init() {
        config.restore(wait: true)
        
        #if os(iOS)
        config.center.boot.send()
        #endif
        
        if Device.isExpandedLayout {
            LayoutService.style = .expanded
        } else {
            LayoutService.style = .compact
        }
    }
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            Home()
            
            #elseif os(macOS)
            WindowComponent(backgroundColor: .background) {
                Home()
                    .background(Color.background)
                    .task {
                        config.center.boot.send()
                    }
            }
            #endif
        }
    }
}
