import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: ScrollViewData = .empty
    
    static func reduce(value: inout ScrollViewData, nextValue: () -> ScrollViewData) {
        value = nextValue()
    }
    
    typealias Value = ScrollViewData
}

struct ScrollViewData: Equatable {
    var offset: CGPoint
    var contentHeight: CGFloat
    
    init(_ offset: CGPoint, contentHeight: CGFloat = 0) {
        self.offset = offset
        self.contentHeight = contentHeight
    }
    
    static var empty: ScrollViewData {
        .init(.zero)
    }
}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset: ScrollViewData
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let frame = proxy.frame(in: .named(coordinateSpace))
                let x = frame.minX
                let y = frame.minY
                
                let contentHeight = frame.height - abs(y)
                
                Color
                    .clear
                    .preference(key: ScrollViewOffsetPreferenceKey.self,
                                value: .init(CGPoint(x: x * -1, y: y * -1),
                                             contentHeight: contentHeight))
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            DispatchQueue.main.async {
                offset = value
            }
        }
    }
}

extension View {
    func readingScrollViewIf(_ condition: Bool, from coordinateSpace: String, into binding: Binding<ScrollViewData>) -> some View {
        Group {
            if condition {
                self.modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
            } else {
                self
            }
        }
    }
    func readingScrollView(from coordinateSpace: String, into binding: Binding<ScrollViewData>) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
    }
}
