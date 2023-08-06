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
    var radius: CGFloat = 50
    @Relay var explorer: ExplorerService
    
    @State var mesh: Mesh? = nil
    @StateObject var selection: SelectionHandler = .init()
    
    var selectedNode: NodeID? {
        selection.selectedNodeIDs.first ?? mesh?.rootNodeID
    }
    
    var body: some View {
        VStack {
            if Device.isExpandedLayout {
                landscapeView
            } else if let mesh {
                SurfaceView(mesh: mesh,
                            selection: selection)
                .showDrawer(selectedNode != nil,
                            node: mesh.nodeWithID(selectedNode ?? .init()))
            }
        }
        .background(Color.alternateBackground)
        .task {
            explorer.preload()
            
            guard explorer.state.lastUpdate == nil else {
                setup()
                return
            }
            
            explorer.center.boot.send()
            setup()
            
        }
        .onAppear {
            
            guard let mesh else { return }
            selection.selectNode(mesh.rootNode())
        }
    }
    
    var landscapeView: some View {
        HStack(spacing: 0) {
            if let mesh {
                SurfaceView(mesh: mesh,
                            selection: selection)
            } else {
                Color.clear
                    .frame(maxHeight: .infinity)
            }
            
            if let mesh,
               let selectedNode,
               let node = mesh.nodeWithID(selectedNode){
                Divider()
                
                InstanceMetaView(node: node)
                    .id(selectedNode)
                    .frame(maxWidth: ContainerConfig.iPhoneScreenWidth)
            }
        }
    }
    
    func setup() {
        let mainNode = LemmyKit.host
        let mesh = Mesh()
        mesh.updateNodeMeta(mesh.rootNode(),
                            style: .baseInstance,
                            meta: .baseInstance)
        
        let instances = explorer.state.linkedInstances.prefix(12)
        var lastR: CGFloat = .zero
        for (i, instance) in instances.enumerated() {
            let ratio = CGFloat(i) / CGFloat(instances.count)
            let angle = Int(ratio * 360)
            
            let nodeViewStyle: NodeViewStyle = .fromInstance(instance)
            var padding: CGFloat = 0
            //50 is the fixed height, 25 is radius from the center point
            //this is basically intersection
            if nodeViewStyle.size.width > lastR - 25,
               nodeViewStyle.size.width < lastR + 25 {
                padding = lastR
            }
            let point = mesh.pointWithCenter(center: .zero,
                                             radius: nodeViewStyle.size.width + padding,
                                             angle: angle.radians)
            lastR = nodeViewStyle.size.width + padding
            let node = mesh.addChild(mesh.rootNode(), at: point)
            //instance details
            mesh.updateNodeMeta(node,
                                style: nodeViewStyle,
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
                     size: .init(width: size.width + 8, height: 50),
                     isMain: true)
    }
    
    static func fromInstance(_ instance: Instance) -> NodeViewStyle {
        #if os(macOS)
        let size: CGSize = instance.domain.size(withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold)])
        #else
        let size: CGSize = instance.domain.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        #endif
        
        return .init(size: .init(width: size.width + 8, height: 50))
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

fileprivate extension View {
    func showDrawer(_ condition: Bool,
                    node: Node?) -> some View {
        self.overlayIf(condition && node != nil, alignment: .top) {
            Group {
                #if os(iOS)
                if let node {
                    Drawer(startingHeight: 100) {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color.background)
                                .shadow(radius: 100)
                            
                            VStack(alignment: .center, spacing: 0) {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 50, height: 8)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, .layer5)
                                
                                InstanceMetaView(node: node)
                                Spacer()
                            }
                            .frame(height: UIScreen.main.bounds.height - 100)
                        }
                    }
                    .rest(at: .constant([100, 480, UIScreen.main.bounds.height - 100]))
                    .impact(.light)
                    .edgesIgnoringSafeArea(.vertical)
                    .transition(.move(edge: .bottom))
                    .id(node.id)
                }
                #endif
            }
        }
    }
}
