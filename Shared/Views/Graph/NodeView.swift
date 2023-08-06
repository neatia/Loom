import Granite
import SwiftUI

struct NodeView: View {
    
    @State var node: Node
    
    var style: NodeViewStyle {
        node.style
    }
    
    @ObservedObject var selection: SelectionHandler
    
    var isSelected: Bool {
        return selection.isNodeSelected(node)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: .layer2)
            .fill(isSelected ? style.foregroundColor : style.color)
            .overlay(RoundedRectangle(cornerRadius: .layer2)
                .stroke(isSelected ? style.strokeColor : Color.clear, lineWidth: isSelected ? 5 : 3))
            .overlay(VStack(alignment: .leading,
                            spacing: 0) {
                Text(node.meta.title)
                    .font(.headline.bold())
                    .lineLimit(1)
                    .foregroundColor(isSelected ? style.color : style.foregroundColor)
                
                if let subtitle = node.meta.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(isSelected ? style.color : style.foregroundColor)
                    .padding(.top, .layer1)
                }
                
            })
            .frame(width: style.size.width + (Device.isMacOS ? 0 : 8), height: style.size.height, alignment: .center)
    }
}

struct NodeViewStyle: GraniteModel {
    var color: Color = .background
    var foregroundColor: Color = .foreground
    var strokeColor: Color = .secondaryForeground
    var size: CGSize = .init(width: 100, height: 50)
    var isMain: Bool = false
    
    enum CodingKeys: CodingKey {
        case size
    }
}

struct NodeViewMeta: GraniteModel {
    var title: String
    var subtitle: String?
    
    init(title: String = "unknown", subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
