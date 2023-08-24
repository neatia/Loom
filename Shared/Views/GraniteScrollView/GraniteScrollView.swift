
import SwiftUI
import Combine

#if os(iOS)

import Foundation

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
    
    private let bgColor: Color
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onFetchMore : FetchMoreHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                bgColor: Color = .clear,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onFetchMore = onFetchMore
        self.onReachedEdge = onReachedEdge
        self.bgColor = bgColor
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
                    .frame(maxHeight: .infinity)
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
    private let content : () -> Content
    
    @State private var status : Status = .idle
    @State private var progress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    
    private let bgColor: Color
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                bgColor: Color = .clear,
                @ViewBuilder content: @escaping () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onReachedEdge = onReachedEdge
        self.content = content
        self.bgColor = bgColor
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
//        VisibilityTrackingScrollView(action: handleVisibilityChanged) {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
//                Color.clear
//                    .trackVisibility(id: "graniteScrollView.reached.top")

                content()
                
//                bgColor
//                    .trackVisibility(id: "graniteScrollView.reached.bottom")
            }
        }
    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        switch change {
            case .shown:
            if id == "graniteScrollView.reached.top" {
                onReachedEdge?(.top)
            } else if id == "graniteScrollView.reached.bottom" {
                onReachedEdge?(.bottom)
            }
            case .hidden:
                break
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

private struct GraniteScrollStoppedKey: EnvironmentKey {
    static let defaultValue: AnyPublisher<CGFloat, Never>? = nil
}

extension EnvironmentValues {
    var graniteScrollStopped: AnyPublisher<CGFloat, Never>? {
        get { self[GraniteScrollStoppedKey.self] }
        set { self[GraniteScrollStoppedKey.self] = newValue }
    }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public enum VisibilityChange {
    case hidden
    case shown
}

public class VisibilityTracker<ID: Hashable>: ObservableObject {
    /// The global bounds of the container view.
    public var containerBounds: CGRect
    
    /// Dictionary containing the offset of every visible view.
    public var visibleViews: [ID:CGFloat]
    
    /// Ids of the visible views, sorted by offset.
    /// The first item is the top view, the last one, the bottom view.
    public var sortedViewIDs: [ID]
    
    /// Action to perform when a view becomes visible or is hidden.
    public var action: Action
    
    /// The id of the top visible view.
    public var topVisibleView: ID? { sortedViewIDs.first }
    
    /// The id of the bottom visible view.
    public var bottomVisibleView: ID? { sortedViewIDs.last }

    /// Action callback signature.
    public typealias Action = (ID, VisibilityChange, VisibilityTracker<ID>) -> ()

    public init(action: @escaping Action) {
        self.containerBounds = .zero
        self.visibleViews = [:]
        self.sortedViewIDs = []
        self.action = action
    }
    
    public func reportContainerBounds(_ bounds: CGRect) {
        containerBounds = bounds
    }
    
    public func reportContentBounds(_ bounds: CGRect, id: ID) {
        let topLeft = bounds.origin
        let size = bounds.size
        let bottomRight = CGPoint(x: topLeft.x + size.width, y: topLeft.y + size.height)
        let isVisible = containerBounds.contains(topLeft) || containerBounds.contains(bottomRight)
        let wasVisible = visibleViews[id] != nil

        if isVisible {
            visibleViews[id] = bounds.origin.y - containerBounds.origin.y
            sortViews()
            if !wasVisible {
                action(id, .shown, self)
            }
        } else {
            if wasVisible {
                visibleViews.removeValue(forKey: id)
                sortViews()
                action(id, .hidden, self)
            }
        }
    }
    
    func sortViews() {
        let sortedPairs = visibleViews.sorted(by: { $0.1 < $1.1 })
        sortedViewIDs = sortedPairs.map { $0.0 }
    }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentVisibilityTrackingModifier<ID: Hashable>: ViewModifier {
    @EnvironmentObject var visibilityTracker: VisibilityTracker<ID>
    
    let id: ID
    
    func body(content: Content) -> some View {
        content
            .id(id)
            .background(
                GeometryReader { proxy in
                    report(proxy: proxy)
                }
            )
    }
    
    func report(proxy: GeometryProxy) -> Color {
        visibilityTracker.reportContentBounds(proxy.frame(in: .global), id: id)
        return Color.clear
    }
}

public extension View {
    func trackVisibility<ID: Hashable>(id: ID) -> some View {
        self
            .modifier(ContentVisibilityTrackingModifier(id: id))
    }
}
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct VisibilityTrackingScrollView<Content, ID>: View where Content: View, ID: Hashable {
    @ViewBuilder let content: Content
    
    @State var visibilityTracker: VisibilityTracker<ID>
    
    public init(action: @escaping VisibilityTracker<ID>.Action, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._visibilityTracker = .init(initialValue: VisibilityTracker<ID>(action: action))
    }
    
    public var body: some View {
        ScrollView {
            content
                .environmentObject(visibilityTracker)
        }
        .background(
            GeometryReader { proxy in
                report(proxy: proxy)
            }
        )
    }
    
    func report(proxy: GeometryProxy) -> Color {
        visibilityTracker.reportContainerBounds(proxy.frame(in: .global))
        return Color.clear
    }
    
}
