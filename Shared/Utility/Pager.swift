//
//  Pager.swift
//  Lemur (iOS)
//
//  Created by PEXAVC on 7/24/23.
//

import Foundation
import Combine
import LemmyKit
import SwiftUI
import GraniteUI

protocol Pageable: Equatable, Identifiable, Hashable {
    var id: String { get }
    var date: Date { get }
    var blocked: Bool { get }
    var person: Person { get }
}

extension Pageable {
    var blocked: Bool {
        false
    }
}

class Pager<Model: Pageable>: ObservableObject {
    
    let insertionQueue: OperationQueue = .init()
    
    var itemIDs: [String]
    var itemMap: [String: Model] = [:]
    var blockedItemMap: [String: Bool] = [:]
    var items: [Model] {
        return itemIDs.compactMap {
            if showBlocked == false,
               blockedItemMap[$0] == true {
                return nil
            } else {
                return itemMap[$0]
            }
        }
    }
    @Published var currentItems: [Model] = []
    @Published var fetchMoreTimedOut: Bool = false
    @Published var isFetching: Bool = false
    @Published var hasMore: Bool = true
    
    var pageSize: Int = 10
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    private(set) var lastItem: Model? = nil
    
    var onRefreshHandler: GraniteScrollView.CompletionHandler?
    
    var pageIndex: Int = 1
    
    private var timerCancellable: Cancellable?
    private var task: Task<Void, Error>? = nil
    
    private var handler: ((Int?) async -> [Model])?
    
    var enableAuxiliaryLoaders: Bool = false
    
    var emptyText: LocalizedStringKey
    
    var showBlocked: Bool
    
    init(emptyText: LocalizedStringKey, showBlocked: Bool = false) {
        self.emptyText = emptyText
        itemIDs = []
        self.handler = nil
        self.showBlocked = showBlocked
        insertionQueue.maxConcurrentOperationCount = 1
        insertionQueue.underlyingQueue = .main
    }
    
    func add(_ items: [Model], pageIndex: Int? = nil) {
        itemIDs = items.map { $0.id }
        for item in items {
            itemMap[item.id] = item
            blockedItemMap[item.id] = item.blocked
        }
        lastItem = items.last ?? lastItem
        
        self.pageIndex = pageIndex ?? self.pageIndex
        self.update()
    }
    
    func insert(_ item: Model) {
        guard itemIDs.contains(item.id) == false else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.itemIDs.insert(item.id, at: 0)
            
            self.itemMap[item.id] = item
            self.blockedItemMap[item.id] = item.blocked
            
            self.update()
        }
    }
    
    func update(item: Model) {
        DispatchQueue.main.async { [weak self] in
            self?.itemMap[item.id] = item
            self?.blockedItemMap[item.id] = item.blocked
            self?.update()
        }
    }
    
    func updateBlockFromPerson(item: Person) {
        if let itemKey = blockedItemMap.keys.first(where: { itemMap[$0]?.person.equals(item) == true }) {
            
            blockedItemMap[itemKey] = blockedItemMap[itemKey] == true ? false : true
            self.update()
        }
    }
    
    func block(item: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.blockedItemMap[item.id] == true {
                self.blockedItemMap[item.id] = false
            } else {
                self.blockedItemMap[item.id] = true
            }
            self.update()
        }
    }
    
    func remove(item: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.itemMap[item.id] = nil
            self.blockedItemMap[item.id] = nil
            let keys = Array(self.itemMap.keys)
            self.itemIDs = keys
            self.update()
        }
    }
    
    @discardableResult
    func hook(_ commit: @escaping ((Int?) async -> [Model])) -> Self {
        self.handler = commit
        return self
    }
    
    func refresh(_ handler: GraniteScrollView.CompletionHandler?) {
        self.onRefreshHandler = handler
        self.fetch(force: true)
    }
    
    func fetch(force: Bool = false) {
        guard hasMore || force else { return }
        
        if force {
            pageIndex = 1
            DispatchQueue.main.async { [weak self] in
                self?.hasMore = true
            }
        }
        
        guard self.isFetching == false else {
            if force {
                clean()
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isFetching = true
        }
        
        self.timerCancellable = Timer.publish(every: 5,
                                              on: .main,
                                              in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] (output) in
                self?.fetchMoreTimedOut = true
                self?.timerCancellable?.cancel()
                self?.timerCancellable = nil
            })
        
        self.task?.cancel()
        self.task = Task(priority: .background) { [weak self] in
            let models: [Model] = (await self?.handler?(self?.pageIndex)) ?? []
            
            
            self?.insertionQueue.addOperation { [weak self] in
                let lastModel = models.last
                
                if !force,
                   let lastItem = self?.lastItem,
                   models.contains(lastItem) {
                    self?.hasMore = false
                }
                
                if models.isEmpty {
                    self?.hasMore = false
                }
                
                self?.lastItem = lastModel
                
                if self?.hasMore == true {
                    self?.pageIndex += 1
                }
                
                if force {
                    for model in models {
                        self?.itemMap[model.id] = model
                        self?.blockedItemMap[model.id] = model.blocked
                    }
                    self?.itemIDs = models.map { $0.id }
                } else if self?.hasMore == true {
                    let items = models.filter { self?.itemIDs.contains($0.id) == false }
                    for model in items {
                        self?.itemMap[model.id] = model
                        self?.blockedItemMap[model.id] = model.blocked
                    }
                    self?.itemIDs.append(contentsOf: items.map { $0.id })
                }
                
                self?.update()
                self?.clean()
                
                if self?.enableAuxiliaryLoaders == false {
                    self?.enableAuxiliaryLoaders = true
                }
            }
        }
    }
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentItems = self.items
        }
    }
    
    func clear() {
        self.pageIndex = 1
        self.hasMore = true
        self.lastItem = nil
        self.itemIDs = []
        self.itemMap = [:]
        self.blockedItemMap = [:]
    }
    
    func tryAgain() {
        clean()
        fetch()
    }
    
    func clean() {
        self.timerCancellable?.cancel()
        self.timerCancellable = nil
        self.isFetching = false
        self.fetchMoreTimedOut = false
        self.onRefreshHandler?()
        self.onRefreshHandler = nil
    }
}

struct PagerScrollView<Model: Pageable, Header: View, AddContent: View, Content: View>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    let cache: LazyScrollViewCache = .init()
    
    let header: () -> Header
    let addContent: () -> AddContent
    let content: (Model) -> Content
    
    let hideDivider: Bool
    let alternateAddPosition: Bool
    
    let contentBGColor: Color
    
    let verticalPadding: CGFloat
    
    let useList: Bool
    
    let cacheEnabled: Bool
    
    //TODO: create style struct for these extra props
    init(_ model: Model.Type,
         hideDivider: Bool = false,
         alternateAddPosition: Bool = false,
         contentBGColor: Color = .clear,
         verticalPadding: CGFloat = 0,
         useList: Bool = false,
         cacheEnabled: Bool = true,
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder inlineBody: @escaping (() -> AddContent) = { EmptyView() },
         @ViewBuilder content: @escaping (Model) -> Content) {
        self.header = header
        self.addContent = inlineBody
        self.content = content
        self.hideDivider = hideDivider
        self.alternateAddPosition = alternateAddPosition
        self.contentBGColor = contentBGColor
        self.verticalPadding = verticalPadding
        self.useList = useList
        self.cacheEnabled = cacheEnabled
    }
    
    var body: some View {
        Group {
            if pager.isEmpty {
                if alternateAddPosition {
                    addContent()
                        .padding(.top, useList ? 20 : 0)
                }
                header()
                    .padding(.top, useList && alternateAddPosition == false ? 20 : 0)
                if !alternateAddPosition {
                    addContent()
                }
                PagerLoadingView<Model>(label: pager.emptyText)
                    .environmentObject(pager)
                    .frame(maxHeight: .infinity)
            } else {
                #if os(macOS)
                normalScrollView
                #else
                if useList {
                    listView
                } else {
                    normalScrollView
                }
                #endif
            }
        }
    }
    
    var normalScrollView: some View {
        
        GraniteScrollView(onRefresh: pager.refresh(_:)) {
            
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                if alternateAddPosition {
                    addContent()
                }
                
                Section(header: header(),
                        footer: PagerFooterLoadingView<Model>().environmentObject(pager)) {
                    
                    if !alternateAddPosition {
                        addContent()
                    }
                    
                    ForEach(pager.currentItems) { item in
                        cache(item)
                    }
                    
                }
            }.padding(.top, 1)
        }
    }
    
    var listView: some View {
        
        GeometryReader { proxy in
            GraniteScrollView(onRefresh: pager.refresh(_:)) {
                List {
                    if alternateAddPosition {
                        addContent()
                            .setupPlainListRow()
                    }
                    
                    Section(header: header()
                        .setupPlainListRow(),
                            footer: PagerFooterLoadingView<Model>().environmentObject(pager)
                        .setupPlainListRow()) {
                            
                            if !alternateAddPosition {
                                addContent()
                                    .setupPlainListRow()
                            }
                            
                            ForEach(pager.currentItems) { item in
                                cache(item)
                                
                            }
                            .setupPlainListRow()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
                .listStyle(PlainListStyle())
                .frame(height: proxy.size.height)
            }
            .frame(height: proxy.size.height)
        }
    }
    
    func cache(_ item: Model) -> some View {
        if let view = cache.viewCache[item.id] {
            
            return view
        }
        
        let view: AnyView = AnyView(
            VStack(spacing: 0) {
                content(item)
                    .padding(.vertical, verticalPadding)
                    //.setupPlainListRow()
                
                if !hideDivider,
                   item.id != pager.lastItem?.id {
                    Divider()
                        //.setupPlainListRow()
                }
            }
            .background(contentBGColor)
        )
        
        if cacheEnabled {
            cache.viewCache[item.id] = view
            cache.flush()
        }
        
        return view
    }
}

extension View {
    func setupPlainListRow() -> some View {
        if #available(macOS 13.0, *) {
            return self
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                     .listRowSeparator(.hidden)
                     .background(Color.clear.onTapGesture { })
        } else {
            return self
        }
    }
}

struct PagerFooterLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var hasMore: Bool {
        pager.hasMore && pager.items.count >= pager.pageSize
    }
    
    var body: some View {
        
        VStack {
            if pager.fetchMoreTimedOut {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.bold())
                    .onTapGesture {
                        GraniteHaptic.light.invoke()
                        pager.tryAgain()
                    }
            } else if pager.isFetching {
                #if os(iOS)
                ProgressView()
                #else
                ProgressView()
                    .scaleEffect(0.6)
                #endif
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: hasMore ? 40 : 0, maxHeight: (hasMore ? 40 : 0))
        .onAppear {
            if pager.enableAuxiliaryLoaders && hasMore {
                pager.fetch()
            }
        }
    }
}

struct PagerLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var label: LocalizedStringKey
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if pager.isFetching {
                    #if os(iOS)
                    ProgressView()
                    #else
                    ProgressView()
                        .scaleEffect(0.6)
                    #endif
                } else {
                    Text(label)
                        .font(.headline.bold())
                }
                Spacer()
            }
            
            Spacer()
        }
    }
}

