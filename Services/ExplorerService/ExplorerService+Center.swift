import Granite
import SwiftUI
import LemmyKit

extension ExplorerService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var linkedInstances: [Instance] = []
            var allowedInstances: [Instance] = []
            var blockedInstances: [Instance] = []
            
            var lastUpdate: Date? = nil
        }
        
        @Event var boot: Boot.Reducer
//        @Event var generate: GenerateGraphData.Reducer
        
//        var pageSize: Int = 12
//        var sections: Int {
//            (state.currentGraphData?.links.count ?? 1) / pageSize
//        }
//
//        func graphData(forPage page: Int = 1) -> Graph? {
//            guard let data = state.currentGraphData else {
//                return nil
//            }
//
//            let startIndex: Int = pageSize * (page - 1)
//            let endIndex: Int = page * pageSize
//
//            let nodes: [Node] = Array(data.nodes[startIndex..<min(data.nodes.count, endIndex)])
//            let links: [Link] = Array(data.links[startIndex..<min(data.links.count, endIndex)])
//
//            return .init(nodes: nodes, links: links)
//        }
        
        @Store(persist: "persistence.lemur.explorer.0010", autoSave: true) public var state: State
    }
}
