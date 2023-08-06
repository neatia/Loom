
import Foundation
import CoreGraphics
import Granite

typealias NodeID = UUID

struct Node: Identifiable, GraniteModel {
    var id: NodeID = NodeID()
    var position: CGPoint = .zero
    var meta: NodeViewMeta = .init()
    var style: NodeViewStyle = .init()
    
    var visualID: String {
        return id.uuidString
        + "\(meta.title.hashValue)"
    }
}

extension Node {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
}
