
import SwiftUI
import Combine

#if os(iOS)

import Foundation

// Heavily influenced and adopted from
// https://github.com/globulus/swiftui-pull-to-refresh/blob/main/Sources/SwiftUIPullToRefresh/SwiftUIPullToRefresh.swift
public struct GraniteScrollView<Content : View, ContentHeader : View> : View {
   
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
    
    enum Direction: Equatable {
        case up(CGFloat)
        case down(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .up(let y), .down(let y):
                return y
            }
        }
        
        var label: String {
            switch self {
            case .down:
                return "down"
            case .up:
                return "up"
            }
        }
        
        var isUp: Bool {
            switch self {
            case .up:
                return true
            default:
                return false
            }
        }
    }
    
    public class DirectionBox: ObservableObject {
        var offset: CGPoint = .zero {
            didSet {
                if initialOffset == nil {
                    initialOffset = offset
                    update()
                }
                
                if offset.y >= 0 && isResting {
                    isResting = false
                    update()
                } else if offset.y <= initialOffset?.y ?? 0 && !isResting {
                    isResting =  true
                    update()
                }
                
                let lastDirection = direction
                if offset.y > oldValue.y {
                    direction = .down(offset.y)
                } else {
                    direction = .up(offset.y)
                }
                
                if direction.label != lastDirection.label {
                    directionChangedAt = lastDirection
                }
                
                let threshold: CGFloat = direction.isUp ? ContainerConfig.iPhoneScreenHeight / 1.5 : 120
                
                let triggerArea: Bool = offset.y > abs(initialOffset?.y ?? 0) + threshold
                if isResting && isShowingAccessory {
                    isShowingAccessory = false
                    update()
                } else if distance > threshold && direction.isUp != isShowingAccessory && triggerArea {
                    isShowingAccessory = direction.isUp
                    update()
                }
            }
        }
        
        var initialOffset: CGPoint? = nil
        
        var directionChangedAt: Direction = .down(0)
        var direction: Direction = .down(0)
        
        var distance: CGFloat {
            guard directionChangedAt.label != direction.label else {
                return 0
            }
            return abs(direction.value - directionChangedAt.value)
        }
        
        var accessoryOffsetY: CGFloat {
            let safeAreaTop = UIApplication.shared.windowSafeAreaInsets.top
            
            if isShowingAccessory {
                return 0
            } else {
                return (initialOffset?.y ?? 0) + (-safeAreaTop)
            }
        }
        var isResting: Bool = true
        var isShowingAccessory: Bool = false
        
        var reachedBottom: Bool = false
        
        func update() {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
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
    private let header : () -> ContentHeader
    private let content : Content
    
    @State private var status : Status = .idle
    @State private var fetchMoreStatus : Status = .idle
    @State private var progress : Double = 0
    @State private var fetchMoreProgress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    @State private var frameHeight: CGFloat = 0
    @StateObject private var directionBox: DirectionBox = .init()
    
    private var hidingHeader: Bool
    
    private let bgColor: Color
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onFetchMore : FetchMoreHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                hidingHeader : Bool = false,
                bgColor: Color = .clear,
                @ViewBuilder header: @escaping () -> ContentHeader = { EmptyView() },
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onFetchMore = onFetchMore
        self.onReachedEdge = onReachedEdge
        self.bgColor = bgColor
        self.header = header
        self.hidingHeader = hidingHeader
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
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(spacing: 0) {
                GraniteScrollViewPositionIndicator(type: .moving)
                    .frame(height: 0)
                    .background(
                        Reader(startDraggingOffset: $startDraggingOffset,
                               onReachedEdge: onReachedEdge)
                    )
                
                if hidingHeader {
                    header()
                        .background(bgColor)
                        .zIndex(1)
                }
                
                if status != .idle {
                    Color.clear
                        .frame(height: status == .loading ? style.threshold : style.threshold * CGFloat(progress))
                        .overlayIf(!hidingHeader, alignment: .top) {
                            Group {
                                if onRefresh != nil {
                                    progressBody
                                }
                            }
                        }
                    
                }
                
                if hidingHeader {
                    ZStack(alignment: .top) {
                        if onRefresh != nil {
                            progressBody
                                .zIndex(0)
                        }
                        
                        VStack(spacing: 0) {
                            content
                                .frame(maxHeight: .infinity)
                        }
                        
                    }
                    .readingScrollViewIf(hidingHeader,
                                         from: "granite.scrollview",
                                         into: .init(get: {
                        return .init(directionBox.offset)
                    }, set: { value in
                        directionBox.offset = value.offset
                        
                        let lastState = directionBox.reachedBottom
                        directionBox.reachedBottom = value.contentHeight <= frameHeight
                        //reached bottom, fire once
                        if lastState != directionBox.reachedBottom,
                           directionBox.reachedBottom {
                            onReachedEdge?(.bottom)
                        }
                    }))
                } else {
                    content
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .coordinateSpace(name: "granite.scrollview")
        .overlayIf(hidingHeader, alignment: .top) {
            VStack(spacing: 0) {
                //if directionBox.isResting == false {
                    header()
                        //.offset(y: directionBox.accessoryOffsetY)
                        .opacity(directionBox.isShowingAccessory ? 1.0 : 0.0)
                //}
                
                Spacer()
            }
            .animation(directionBox.isResting ? nil : (directionBox.isShowingAccessory ? .linear(duration: 0.6) : .easeOut(duration: 0.7)), value: directionBox.isShowingAccessory)
            .overlay(alignment: .top) {
                Rectangle()
                    .frame(height: Device.statusBarHeight)
                    .foregroundColor(bgColor.opacity(0.6))

            }
        }
        .background(GraniteScrollViewPositionIndicator(type: .fixed))
        .onPreferenceChange(GraniteScrollViewPositionIndicator.PositionPreferenceKey.self) { values in
            guard status != .loading, onRefresh != nil else {
                return
            }
            
            DispatchQueue.main.async {
                frameHeight = values.first?.frame.height ?? frameHeight
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
public struct GraniteScrollView<Content : View, ContentHeader : View> : View {
   
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
                hidingHeader : Bool = false,
                bgColor: Color = .clear,
                @ViewBuilder header: @escaping () -> ContentHeader = { EmptyView() },
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
                StandardProgressView()
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
