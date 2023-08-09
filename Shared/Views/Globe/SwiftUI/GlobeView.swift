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
    var scene: GlobeScene
    var data: [GlobeNode]
    
    public init(_ data: [GlobeNode] = [], rootIndex root: Int = 0) {
        self.data = data
        self.scene = .init(data, rootIndex: root)
    }
    
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
        if scene.isReady == false {
            scene.setup(data)
        }
    }
    #endif
    
    public func run() {
        scene.animate()
    }
}
