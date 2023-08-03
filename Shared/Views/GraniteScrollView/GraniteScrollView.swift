#if os(iOS)

import Foundation
import SwiftUI

// Heavily influenced and adopted from
// https://github.com/globulus/swiftui-pull-to-refresh/blob/main/Sources/SwiftUIPullToRefresh/SwiftUIPullToRefresh.swift
public struct GraniteScrollView<Content : View> : View {
   
    private enum Status {
        case idle
        case dragging
        case primed
        case loading
    }
    
    public enum Edge {
        case top
        case bottom
    }
    
    public typealias ReachedEdgeHandler = (Edge) -> Void
    public typealias CompletionHandler = () -> Void
    public typealias RefreshHandler = (@escaping CompletionHandler) -> Void
    public typealias FetchMoreHandler = (@escaping CompletionHandler) -> Void
    
    @Environment(\.GraniteScrollViewStyle) var style
    
    private let axes : Axis.Set
    private let showsIndicators : Bool
    private let onRefresh : RefreshHandler?
    private let onFetchMore : FetchMoreHandler?
    private let onReachedEdge : ReachedEdgeHandler?
    private let content : Content
    
    @State private var status : Status = .idle
    @State private var fetchMoreStatus : Status = .idle
    @State private var progress : Double = 0
    @State private var fetchMoreProgress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onFetchMore : FetchMoreHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onFetchMore = onFetchMore
        self.onReachedEdge = onReachedEdge
        self.content = content()
    }
    
    var progressBody: some View {
        ZStack {
            if status == .loading {
                ActivityIndicator()
                    .offset(y: -style.progressOffset)
            }
            else if status != .idle {
                PullIndicator()
                    .rotationEffect(.degrees(180 * progress))
                    .opacity(progress)
                    .offset(y: -style.progressOffset)
            }
        }
    }
    
    var progressFetchBody: some View {
        ZStack {
            if status == .loading {
                ActivityIndicator()
                    .offset(y: style.fetchMoreOffset)
            }
            else if status != .idle {
                PullIndicator()
                    .rotationEffect(.degrees(180 * fetchMoreProgress))
                    .opacity(fetchMoreProgress)
                    .offset(y: style.fetchMoreOffset)
            }
        }
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(spacing: 0) {
                GraniteScrollViewPositionIndicator(type: .moving)
                    .frame(height: 0)
                    .overlay(
                        Reader(startDraggingOffset: $startDraggingOffset,
                               onReachedEdge: onReachedEdge)
                    )
                
                if status != .idle {
                    Color.clear
                        .frame(height: status == .loading ? style.threshold : style.threshold * CGFloat(progress))
                }
                
                content
                    .overlay(onRefresh != nil ? progressBody : nil, alignment: .top)
            }
        }
        .background(GraniteScrollViewPositionIndicator(type: .fixed))
        .onPreferenceChange(GraniteScrollViewPositionIndicator.PositionPreferenceKey.self) { values in
            guard status != .loading, onRefresh != nil else {
                return
            }
           
            guard startDraggingOffset == .zero else {
                status = .idle
                return
            }
            
            if status == .idle {
                status = .dragging
            }

            DispatchQueue.main.async {
                let movingY = values.first { $0.type == .moving }?.y ?? 0
                let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                let offset : CGFloat = movingY - fixedY
                
                guard offset > 0 else {
                    return
                }

                progress = Double(min(max(abs(offset) / style.threshold, 0.0), 1.0))
                
                if offset > style.threshold && status == .dragging {
                    status = .primed
                }
                else if offset < style.threshold && status == .primed {
                    withAnimation(.linear(duration: 0.2)) {
                        status = .loading
                    }
                    
                    onRefresh? {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            withAnimation {
                                self.status = .idle
                                self.progress = 0
                            }
                        }
                      
                    }
                }
            }
        }
        .onTapGesture {
            
        }
    }
    
}

/* Indicators */

private struct ActivityIndicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        uiView.startAnimating()
    }
}
#else
import SwiftUI
public struct GraniteScrollView<Content : View> : View {
   
    private enum Status {
        case idle
        case dragging
        case primed
        case loading
    }
    
    public enum Edge {
        case top
        case bottom
    }
    
    public typealias ReachedEdgeHandler = (Edge) -> Void
    public typealias CompletionHandler = () -> Void
    public typealias RefreshHandler = (@escaping CompletionHandler) -> Void
    
    @Environment(\.GraniteScrollViewStyle) var style
    
    private let axes : Axis.Set
    private let showsIndicators : Bool
    private let onRefresh : RefreshHandler?
    private let onReachedEdge : ReachedEdgeHandler?
    private let content : Content
    
    @State private var status : Status = .idle
    @State private var progress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onReachedEdge = onReachedEdge
        self.content = content()
    }
    
    var progressBody: some View {
        ZStack {
            if status == .loading {
                #if os(iOS)
                ProgressView()
                    .offset(y: -style.progressOffset)
                #else
                ProgressView()
                    .scaleEffect(0.6)
                    .offset(y: -style.progressOffset)
                #endif
            }
            else if status != .idle {
                PullIndicator()
                    .rotationEffect(.degrees(180 * progress))
                    .opacity(progress)
                    .offset(y: -style.progressOffset)
            }
        }
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(spacing: 0) {
                GraniteScrollViewPositionIndicator(type: .moving)
                    .frame(height: 0)
                //TODO: macOS compatible reader
                
                if status != .idle {
                    Color.clear
                        .frame(height: status == .loading ? style.threshold : style.threshold * CGFloat(progress))
                }
                
                content
                    .overlay(onRefresh != nil ? progressBody : nil, alignment: .top)
            }
        }
        .background(GraniteScrollViewPositionIndicator(type: .fixed))
        .onPreferenceChange(GraniteScrollViewPositionIndicator.PositionPreferenceKey.self) { values in
            guard status != .loading, onRefresh != nil else {
                return
            }
           
            guard startDraggingOffset == .zero else {
                status = .idle
                return
            }
            
            if status == .idle {
                status = .dragging
            }

            DispatchQueue.main.async {
                let movingY = values.first { $0.type == .moving }?.y ?? 0
                let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                let offset : CGFloat = movingY - fixedY
                
                guard offset > 0 else {
                    return
                }

                progress = Double(min(max(abs(offset) / style.threshold, 0.0), 1.0))
                
                if offset > style.threshold && status == .dragging {
                    status = .primed
                }
                else if offset < style.threshold && status == .primed {
                    withAnimation(.linear(duration: 0.2)) {
                        status = .loading
                    }
                    
                    onRefresh? {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            withAnimation {
                                self.status = .idle
                                self.progress = 0
                            }
                        }
                      
                    }
                }
            }
        }
        .onTapGesture {
            
        }
    }
    
}
#endif

private struct PullIndicator : View {
    
    var body: some View {
        Image(systemName: "arrow.down")
            .resizable()
            .frame(width: 12, height: 12)
    }
    
}
