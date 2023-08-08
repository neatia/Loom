//
//  GlobeView.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import SwiftUI
import SceneKit
import Granite
import GraniteUI

#if os(iOS)
public typealias GenericControllerRepresentableContext = UIViewRepresentableContext
typealias GenericControllerRepresentable = UIViewControllerRepresentable
typealias GenericViewRepresentable = UIViewRepresentable
#else
import AppKit
import SceneKit.ModelIO

public typealias GenericControllerRepresentableContext = NSViewRepresentableContext
typealias GenericControllerRepresentable = NSViewControllerRepresentable
typealias GenericViewRepresentable = NSViewRepresentable
#endif

public struct GlobeView : GenericViewRepresentable {
    var scene: GlobeScene = .init()
    
    public init() {}
    
    #if os(iOS)
    public func makeUIView(context: GenericControllerRepresentableContext<GlobeView>) -> SCNView {
        
        scene.setup()
        
        return scene.sceneView
    }

    public func updateUIView(_ scnView: SCNView, context: Context) {
        
    }
    #else
    public func makeNSView(context: GenericControllerRepresentableContext<GlobeView>) -> SCNView {
        
        scene.setup()
        
        return scene.sceneView
    }

    public func updateNSView(_ scnView: SCNView, context: Context) {
        
    }
    #endif
    
    public func run() {
        scene.animate()
    }
}
