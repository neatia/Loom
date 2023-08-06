//
//  GlobeExplorer.swift
//  Lemur
//
//  Created by PEXAVC on 8/4/23.
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
        mesh.updateNodeMeta(mesh.rootNode(),
                            style: .baseInstance,
                            meta: .baseInstance)
        
        let instances = explorer.state.linkedInstances.prefix(12)
        for (i, instance) in instances.enumerated() {
            let ratio = CGFloat(i) / CGFloat(instances.count)
            let angle = Int(ratio * 360)
            let point = mesh.pointWithCenter(center: .zero,
                                             radius: radius,
                                             angle: angle.radians)
            let node = mesh.addChild(mesh.rootNode(), at: point)
            //instance details
            mesh.updateNodeMeta(node,
                                style: .fromInstance(instance),
                                meta: .fromInstance(instance))
        }
        
        self.mesh = mesh
    }
}

extension NodeViewStyle {
    
    static var baseInstance: NodeViewStyle {
        #if os(macOS)
        let size: CGSize = LemmyKit.host.size(withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold)])
        #else
        let size: CGSize = LemmyKit.host.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        #endif
        
        return .init(color: Brand.Colors.yellow,
                     foregroundColor: .alternateBackground,
                     size: .init(width: size.width + 16, height: 50),
                     isMain: true)
    }
    
    static func fromInstance(_ instance: Instance) -> NodeViewStyle {
        #if os(macOS)
        let size: CGSize = instance.domain.size(withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold)])
        #else
        let size: CGSize = instance.domain.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        #endif
        
        return .init(size: .init(width: size.width + 16, height: 50))
    }
        
}

extension NodeViewMeta {
    static var root: NodeViewMeta {
        .init(title: "root")
    }
    
    static var child: NodeViewMeta {
        .init(title: "child")
    }
    
    static var baseInstance: NodeViewMeta {
        return .init(title: LemmyKit.host)
    }
    
    static func fromInstance(_ instance: Instance) -> NodeViewMeta {
        .init(title: instance.domain,
              subtitle: instance.published.serverTimeAsDate?.timeAgoDisplay())
    }
}
