//
//  GlobeExplorer.swift
//  Lemur
//
//  Created by Ritesh Pakala on 8/4/23.
//

import Foundation
import SwiftUI
import Granite
import LemmyKit

struct GlobeExplorerView: View {
    var radius: CGFloat = 100
    @Relay var explorer: ExplorerService
    
    @State var mesh: Mesh? = nil
    @State var selection: SelectionHandler = .init()
    
    
    var body: some View {
        VStack {
            if let mesh {
                SurfaceView(mesh: mesh,
                            selection: selection)
            } else {
                Color.clear
                    .frame(maxHeight: .infinity)
            }
        }
        .task {
            explorer.preload()
            
            guard explorer.state.lastUpdate == nil else {
                setup()
                return
            }
            
            explorer.center.boot.send()
            setup()
        }
    }
    
    func setup() {
        let mainNode = LemmyKit.host
        let mesh = Mesh()
        mesh.updateNodeText(mesh.rootNode(), string: mainNode)
        
        let instances = explorer.state.linkedInstances.prefix(12)
        
        for (i, instance) in instances.enumerated() {
            let ratio = CGFloat(i) / CGFloat(instances.count)
            let angle = Int(ratio * 360)
            let point = mesh.pointWithCenter(center: .zero,
                                             radius: radius,
                                             angle: angle.radians)
            let node = mesh.addChild(mesh.rootNode(), at: point)
            mesh.updateNodeText(node, string: instance.domain)
        }
        
        self.mesh = mesh
    }
}
