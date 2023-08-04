import SwiftUI
import Granite

struct GraphView: View {
    @GraniteAction<Int> var tapped
    
    @ObservedObject var viewModel: GraphViewModel
    
    enum Constant {
        static let fontSize = 12.0
    }
    
    @State var isDragging = false
    @State var draggingIndex: Int?
    @State var previous: Date?
    
    var drag: some Gesture {
        let tap = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { drag in
                if isDragging, let index = draggingIndex {
                    viewModel.dragNode(at: index, location: drag.location)
                } else {
                    draggingIndex = viewModel.hitTest(point: drag.location)
                }
                isDragging = true
            }
            .onEnded { _ in
                if let index = draggingIndex {
                    viewModel.stopDraggingNode(at: index)
                    DispatchQueue.main.async {
                        tapped.perform(index)
                    }
                }
                isDragging = false
                draggingIndex = nil
            }
        return tap
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                viewModel.canvasSize = size
                viewModel.updateSimulation()
                
                context.transform = viewModel.modelToView
                
                let links = Path { drawing in
                    for link in viewModel.linkSegments() {
                        drawing.move(to: link.0)
                        drawing.addLine(to: link.1)
                    }
                }
                
                context.stroke(links, with: .color(white: 0.9),
                               lineWidth: viewModel.linkWidthModel)
                
                if viewModel.showIDs {
                    context.transform = .identity
                    let font = Font.system(size: Constant.fontSize, weight: .bold)
                    for node in viewModel.graph.nodes {
                        let textView = Text(node.id)
                            .font(font)
                            .foregroundColor(Color.foreground)
                        let origin = node.position.applying(viewModel.modelToView)
                        
                        let rt = context.resolve(textView)
                        let textSize = rt.measure(in: CGSize(width: .max, height: .max))
                        
                        context.fill(.init(roundedRect: CGRect(origin: .init((origin.x - textSize.width / 2) - 8, (origin.y - textSize.height / 2) - 4), size: .init(width: textSize.width + 16, height: textSize.height + 8)), cornerRadius: 4), with: .color(Color.alternateBackground))
                        
                        context.draw(textView,
                                     at: origin)
                        
                        
                    }
                }
            }
            .gesture(drag)
        }
    }
}




