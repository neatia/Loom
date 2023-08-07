
import Foundation
import CoreGraphics

struct DragInfo {
    var id: NodeID
    var originalPosition: CGPoint
}

class SelectionHandler: ObservableObject {
    @Published var draggingNodes: [DragInfo] = []
    @Published private(set) var selectedNodeIDs: [NodeID] = []
    @Published private(set) var selectedNodeDragIDs: [NodeID] = []
    
    @Published var editingText: String = ""
    
    func selectNode(_ node: Node) {
        selectedNodeIDs = [node.id]
        editingText = node.meta.title
    }
    
    func selectNodeForDragging(_ node: Node) {
        selectedNodeDragIDs = [node.id]
    }
    
    func isNodeSelected(_ node: Node) -> Bool {
        return selectedNodeIDs.contains(node.id)
    }
    
    func selectedNodes(in mesh: Mesh) -> [Node] {
        return selectedNodeIDs.compactMap { mesh.nodeWithID($0) }
    }
    
    func selectedNodesDrag(in mesh: Mesh) -> [Node] {
        return selectedNodeDragIDs.compactMap { mesh.nodeWithID($0) }
    }
    
    func onlySelectedNode(in mesh: Mesh) -> Node? {
        let selectedNodes = self.selectedNodes(in: mesh)
        if selectedNodes.count == 1 {
            return selectedNodes.first
        }
        return nil
    }
    
    func startDragging(_ mesh: Mesh) {
        draggingNodes = selectedNodesDrag(in: mesh)
            .map { DragInfo(id: $0.id, originalPosition: $0.position) }
    }
    
    func stopDragging(_ mesh: Mesh) {
        draggingNodes = []
    }
}
