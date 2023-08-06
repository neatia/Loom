
import SwiftUI

struct NodeMapView: View {
    @ObservedObject var selection: SelectionHandler
    @Binding var nodes: [Node]
    
    var body: some View {
        ZStack {
            ForEach(nodes, id: \.visualID) { node in
                NodeView(node: node, selection: self.selection)
                    .offset(x: node.position.x, y: node.position.y)
                    .onTapGesture {
                        self.selection.selectNode(node)
                    }
            }
        }
    }
}
