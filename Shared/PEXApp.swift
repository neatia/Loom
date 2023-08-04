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
    
    @Relay var config: ConfigService
    
    let pubDidFinishLaunching = NotificationCenter.default
            .publisher(for: NSNotification.Name("nyc.stoic.Lemur.DidFinishLaunching"))
    
    init() {
        #if os(iOS)
        config.center.boot.send()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            Home()
            
            #elseif os(macOS)
            
            /*
             Home()
                 .preferredColorScheme(.dark)
                 .frame(minWidth: 800,
                        minHeight: 600)
                 .background(Brand.Colors.black)
                 .onReceive(pubDidFinishLaunching) { _ in
                     GraniteNavigationWindow.backgroundColor = NSColor(Brand.Colors.black)
                     
                     config.center.boot.send()
                 }
             
             */
            
            EmptyComponent()
            .onReceive(pubDidFinishLaunching) { _ in
                GraniteNavigationWindow.backgroundColor = NSColor(Color.background)
                
                GraniteNavigationWindow.shared.addWindow(id: "main",
                                                         title: "",
                                                         style: .init(size: .init(width: 900,
                                                                                  height: 600), minSize: .init(width: 900, height: 600), styleMask: .resizable),
                                                         isMain: true) {
                    Home()
                        .background(Color.background)
                        .task {
                            //TODO: possible resizing race?
                            
                            config.center.boot.send()
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                if config.state.style == .expanded || config.state.style == .unknown {
//                                    #if os(macOS)
//                                    ConfigService.expandWindow(close: config.state.closeFeedDisplayView)
//                                    #endif
//                                }
//                            }
                        }
                }
            }
            #endif
        }
    }
}
struct EmptyComponent: GraniteComponent {
    struct Center: GraniteCenter {
        
        struct State: GraniteState {
            
        }
        
        @Store var state: State
    }
    
    @Command var center: Center
}

extension EmptyComponent: View {
    var view: some View {
        ZStack {
            Text("Lemur")
        }
    }
}
