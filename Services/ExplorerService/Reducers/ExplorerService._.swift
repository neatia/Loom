import Granite
import LemmyKit
import SwiftUI

extension ExplorerService {
    struct Boot: GraniteReducer {
        typealias Center = ExplorerService.Center
        
        @Event var storeGraphData: StoreGraphData.Reducer
        
        func reduce(state: inout Center.State) {
            _ = Task.detached {
                let fedInstances = await Lemmy.instances()
//                let mainNode: Node = .init(id: LemmyKit.host,
//                                           group: 1,
//                                           position: .init(0.5, 0.5),
//                                           velocity: .zero,
//                                           isInteractive: true)
//
//                let instances = Array(fedInstances?.linked ?? [])
//
                
    
                storeGraphData.send(
                    StoreGraphData.Meta(linked: fedInstances?.linked ?? [],
                                        allowed: fedInstances?.allowed ?? [],
                                        blocked: fedInstances?.blocked ?? []))
            }
        }
    }
    
    struct StoreGraphData: GraniteReducer {
        typealias Center = ExplorerService.Center
        
        struct Meta: GranitePayload, GraniteModel {
            var linked: [Instance]
            var allowed: [Instance]
            var blocked: [Instance]
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            state.linkedInstances = meta?.linked ?? []
            state.allowedInstances = meta?.allowed ?? []
            state.blockedInstances = meta?.blocked ?? []
            state.lastUpdate = .init()
        }
    }
//
//    struct GenerateGraphData: GraniteReducer {
//        typealias Center = ExplorerService.Center
//
//        struct Meta: GranitePayload, GraniteModel {
//            var page: Int
//        }
//
//        @Payload var meta: Meta?
//
//        func reduce(state: inout Center.State) {
//            guard let meta else { return }
//
//            var pageSize: Int = 4
//            let startIndex = (meta.page - 1) * pageSize
//            let endIndex = (meta.page) * pageSize
//            let instances = Array(state.linkedInstances[startIndex..<endIndex])
//
//            state.count += 1
//            let mainNode: Node = .init(id: LemmyKit.host,
//                                       group: 1,
//                                       position: .init(0.5, 0.5),
//                                       velocity: .zero,
//                                       isInteractive: true)
//
//            state.currentGraphData = ExplorerService.generateGraph(mainNode: mainNode, instances: instances)
//
//            state.lastUpdate = .init()
//        }
//    }
//
//    static func generateGraph(mainNode: Node, instances: [Instance]) -> Graph {
//        var nodes: [Node] = [mainNode]
//        var links: [Link] = []
//
//        let instanceCount: CGFloat = CGFloat(instances.count)
//
//        let radius: CGFloat = 0.5
//        for (i, instance) in instances.enumerated() {
//            let ratio: CGFloat = CGFloat(i) / (instanceCount)
//            let x1 = cos(ratio * Double.pi * 2)
//            let y1 = sin(ratio * Double.pi * 2)
//            let startX = radius + (radius * x1)
//            let startY = radius + (radius * y1)
//
//
//            let instanceNode: Node = .init(id: instance.domain, group: 1, position: .init(x: startX, y: startY), velocity: .zero, isInteractive: true)
//            let link: Link = .init(source: mainNode.id, target: instance.domain, value: instance.id)
//
//            nodes.append(instanceNode)
//            links.append(link)
//        }
//
//        return .init(nodes: nodes, links: links)
//    }
}
