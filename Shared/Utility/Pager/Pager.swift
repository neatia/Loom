//
//  Pager.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/24/23.
//

import Foundation
import Combine
import LemmyKit
import SwiftUI
import Granite
import GraniteUI
import LinkPresentation
import UniformTypeIdentifiers

protocol Pageable: Equatable, Identifiable, Hashable {
    var id: String { get }
    var date: Date { get }
    var blocked: Bool { get }
    var person: Person { get }
    var thumbUrl: URL? { get }
}

extension Pageable {
    var blocked: Bool {
        false
    }
    
    var thumbUrl: URL? {
        nil
    }
}

struct PageableMetadata: Hashable {
    var linkMeta: LPLinkMetadata?
    var imageThumb: GraniteImage?
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
    
    var itemMetadatas: [String: PageableMetadata] = [:]
    
    //main data source
    #if os(macOS)
    @Published var currentItems: [Model] = []
    #else
    var currentItems: [Model] = []
    #endif
    
    var fetchMoreTimedOut: Bool = false
    var hasMore: Bool = true
    
    @Published var isFetching: Bool = false
    
    var pageSize: Int = ConfigService.Preferences.pageLimit
    
    var isEmpty: Bool {
        currentItems.isEmpty
    }
    
    private(set) var firstItem: Model? = nil
    private(set) var lastItem: Model? = nil
    
    var onRefreshHandler: GraniteScrollView.CompletionHandler?
    
    var pageIndex: Int = 1
    
    private var timerCancellable: Cancellable?
    private var task: Task<Void, Error>? = nil
    private var rlProcessorTask: Task<Void, Error>? = nil
    
    //handlers
    private var handler: ((Int?) async -> [Model])?
    private var progressHandler: ((CGFloat) -> Void)?
    private var currentItemsHandler: (([Model]) -> Void)?
    
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
    
    @discardableResult
    func hook(_ commit: @escaping ((Int?) async -> [Model])) -> Self {
        self.handler = commit
        return self
    }
    
    func progress(_ commit: @escaping ((CGFloat?) -> Void)) {
        self.progressHandler = commit
    }
    
    func getItems(_ commit: @escaping (([Model]) -> Void)) {
        self.currentItemsHandler = commit
    }
    
    func refresh(_ handler: GraniteScrollView.CompletionHandler?) {
        self.onRefreshHandler = handler
        self.reset()
    }
    
    func fetch(force: Bool = false) {
        guard hasMore || force else { return }
        
        if force {
            LoomLog("Forcing fetch", level: .debug)
            pageIndex = 1
            DispatchQueue.main.async { [weak self] in
                self?.hasMore = true
            }
        }
        
        guard self.isFetching == false else {
            LoomLog("Fetch in progress", level: .error)
            if force {
                clean()
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isFetching = true
        }
        
        self.timerCancellable = Timer.publish(every: 10,
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
            guard let handler = self?.handler else {
                LoomLog("🔴 Fetch failed | no handler", level: .error)
                self?.clean()
                return
            }
            
            let models: [Model] = (await handler(self?.pageIndex))
            
            guard let this = self else { return }
            
            LoomLog("🟢 Fetch succeeded | \(models.count) items", level: .debug)
            
            let thumbURLs: [(String, URL?)] = models.compactMap { ($0.id, $0.thumbUrl) }
                
            if thumbURLs.isEmpty {
                insertModels(models, force: force)
            } else {
                let count = CGFloat(thumbURLs.count)
                self?.rlProcessorTask?.cancel()
                self?.rlProcessorTask = Task(priority: .userInitiated) { [weak self] in
                    var completed: CGFloat = 0.0
                    for (id, url) in thumbURLs {
                        guard let url else { continue }
                        let time = CFAbsoluteTimeGetCurrent()
                        this.itemMetadatas[id] = await this.getLPMetadata(url: url)
                        if this.itemMetadatas[id] != nil {
                            LoomLog("Rich Link Data received: \(CFAbsoluteTimeGetCurrent() - time)", level: .info)
                        }
                        
                        completed += 1
                        
                        let progress = completed / count
                        DispatchQueue.main.async { [weak self] in
                            self?.progressHandler?(progress)
                        }
                    }
                    this.insertModels(models, force: force)
                }
            }
        }
    }
    
    func insertModels(_ models: [Model], force: Bool) {
        _ = Task.detached { [weak self] in
            
            self?.insertionQueue.addOperation { [weak self] in
                let lastModel = models.last
                
                //TODO: These are not gaurunteeable
                if !force,
                   let lastItem = self?.lastItem,
                   models.contains(lastItem) {
                    //self?.hasMore = false
                }

                if models.isEmpty {
                    //self?.hasMore = false
                }
                
                self?.lastItem = lastModel
                
                if self?.pageIndex == 1 {
                    self?.firstItem = models.first
                }
                
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
                //self?.clean()
                
                if self?.enableAuxiliaryLoaders == false {
                    self?.enableAuxiliaryLoaders = true
                }
            }
        }
    }
    
    @MainActor
    func getLPMetadata(url: URL) async -> PageableMetadata? {
        let provider = LPMetadataProvider()
        let metaData = try? await provider.startFetchingMetadata(for: url)
        let type = String(describing: UTType.image)
        guard let imageProvider = metaData?.imageProvider else {
            return nil
        }
        
        var image: GraniteImage?
        if imageProvider.hasItemConformingToTypeIdentifier(type) {
            guard let item = try? await imageProvider.loadItem(forTypeIdentifier: type) else {
                image = nil
                return .init(linkMeta: metaData, imageThumb: image)
            }
            
            if item is GraniteImage {
                image = item as? GraniteImage
            }
            
            if item is URL {
                guard let url = item as? URL,
                      let data = try? Data(contentsOf: url) else { return nil }
                
                image = GraniteImage(data: data)
            }
            
            if item is Data {
                guard let data = item as? Data else { return nil }
                
                image = GraniteImage(data: data)
            }
        }
        
        return .init(linkMeta: metaData, imageThumb: image)
    }
}

//MARK: -- datasource modifiers
extension Pager {
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
        blockedItemMap.keys.forEach { [weak self] key in
            if itemMap[key]?.person.equals(item) == true {
                self?.blockedItemMap[key] = self?.blockedItemMap[key] == true ? false : true
            }
        }
        
        self.update()
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
}

//MARK: user-interactive modifiers
extension Pager{
    func reset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.clear()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fetch(force: true)
        }
    }
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentItems = self.items
            self.currentItemsHandler?(self.currentItems)
            self.clean()
        }
    }
    
    func clear() {
        self.clean()
        self.pageIndex = 1
        self.hasMore = true
        self.lastItem = nil
        self.itemIDs = []
        self.itemMap = [:]
        self.blockedItemMap = [:]
        self.currentItems = []
    }
    
    func tryAgain() {
        clean()
        fetch()
    }
    
    func clean() {
        self.timerCancellable?.cancel()
        self.timerCancellable = nil
        self.fetchMoreTimedOut = false
        self.isFetching = false
        self.onRefreshHandler?()
        self.onRefreshHandler = nil
        self.rlProcessorTask?.cancel()
        self.rlProcessorTask = nil
        self.progressHandler?(0.0)
    }
}

struct PageableMetadataKey: EnvironmentKey {
    static var defaultValue: PageableMetadata? = nil
}

extension EnvironmentValues {
    var pagerMetadata: PageableMetadata? {
        get { self[PageableMetadataKey.self] }
        set { self[PageableMetadataKey.self] = newValue }
    }
}
