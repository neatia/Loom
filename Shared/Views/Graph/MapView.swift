
import SwiftUI

struct MapView: View {
    @ObservedObject var selection: SelectionHandler
    @ObservedObject var mesh: Mesh
    
    var body: some View {
        ZStack {
            EdgeMapView(edges: $mesh.links)
            NodeMapView(selection: selection, nodes: $mesh.nodes)
        }
    }
}
