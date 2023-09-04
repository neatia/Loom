//
//  Pager.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/24/23.
//

import Foundation
import Combine
import FederationKit
import SwiftUI
import Granite
import GraniteUI
import LinkPresentation
import UniformTypeIdentifiers
import ModerationKit

public protocol Pageable: Equatable, Identifiable, Hashable {
    var id: String { get }
    var date: Date { get }
    var blocked: Bool { get }
    var shouldHide: Bool { get }
    var person: FederatedPerson { get }
    var thumbURL: URL? { get }
    var postURL: URL? { get }
}

extension Pageable {
    var blocked: Bool {
        false
    }
    
    public var thumbURL: URL? {
        nil
    }
    
    public var postURL: URL? {
        nil
    }
    
    public var shouldHide: Bool {
        false
    }
}

struct PageableMetadata: Hashable {
    static var fetchTimeout: Double = 5.0
    static var fetchLPTimeout: Double = 2.5
    
    var linkMeta: LPLinkMetadata?
    var imageThumb: GraniteImage?
}

public class PagerFilter {
    //hides models to appear that have shouldHide set to true
    static var enableForNSFW: Bool = false
    static var enableForBots: Bool = false
    static var enableForNSFWExtended: Bool = false
    static var enableForKeywords: Bool = false
    static var filterKeywords: FilterConfig = .empty
    
    static var isEnabled: Bool {
        enableForNSFW || enableForBots || enableForKeywords
    }
}

public class PagerConfig {
    static var manuallyFetchMoreContent: Bool = false
}

public class Pager<Model: Pageable>: ObservableObject {
    
    let insertionQueue: OperationQueue = .init()
    
    //data source
    var lastItemIds: [String] = []
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
    var lastItems: [Model] {
        return lastItemIds.compactMap {
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
    var currentItems: [Model] = []
    
    var currentLastItems: [Model] = [] {
        didSet {
            guard currentItems.isNotEmpty else { return }
            shouldUpdate = true
        }
    }
    var shouldReset: Int = 0 {
        didSet {
            self.objectWillChange.send()
        }
    }
    #else
    @Published var currentItems: [Model] = []
    #endif
    
    //Primarily used for macOS
    var shouldUpdate: Bool = false {
        didSet {
            guard shouldUpdate else { return }
            self.objectWillChange.send()
        }
    }
    
    //states
    var fetchMoreTimedOut: Bool = false
    var hasMore: Bool = true
    var canAutoFetch: Bool {
        (hasMore && currentItems.isNotEmpty) && PagerConfig.manuallyFetchMoreContent == false
    }
    
    @Published var isFetching: Bool = false
    
    var initialFetch: Bool = true
    
    var isEmpty: Bool {
        currentItems.isEmpty
    }
    
    private(set) var firstItem: Model? = nil
    private(set) var lastItem: Model? = nil
    
    //data
    var pageIndex: Int = 1
    var pageSize: Int = ConfigService.Preferences.pageLimit
    
    //tasks
    private var timerCancellable: Cancellable?
    private var task: Task<Void, Error>? = nil
    private var rlProcessorTask: Task<Void, Error>? = nil
    
    //handlers
    var onRefreshHandler: GraniteScrollView.CompletionHandler?
    private var handler: ((Int?) async -> [Model])?//fetch
    private var progressHandler: ((CGFloat) -> Void)?
    private var currentItemsHandler: (([Model]) -> Void)?
    private var resetHandler: (() -> Void)?
    
    //preferences
    var enableAuxiliaryLoaders: Bool = false
    
    var emptyText: LocalizedStringKey
    
    var showBlocked: Bool
    
    var isStatic: Bool
    
    init(emptyText: LocalizedStringKey,
         showBlocked: Bool = false,
         isStatic: Bool = false) {
        self.emptyText = emptyText
        itemIDs = []
        self.handler = nil
        self.showBlocked = showBlocked
        self.isStatic = isStatic
        insertionQueue.maxConcurrentOperationCount = 1
        insertionQueue.underlyingQueue = .main
        
        if isStatic {
            hasMore = false
        }
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
        
        DispatchQueue.main.async { [weak self] in
            self?.fetch(force: true)
        }
    }
    
    @discardableResult
    func onReset(_ commit: @escaping (() -> Void)) -> Self {
        self.resetHandler = commit
        return self
    }
    
    @MainActor
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
        
        self.isFetching = true
        
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
            self?.initialFetch = false
            
            guard let handler = self?.handler else {
                LoomLog("🔴 Fetch failed | no handler", level: .error)
                self?.clean()
                return
            }
            
            let results: [Model] = (await handler(self?.pageIndex))
            
            //This used to occuer in insertModels(_:)
            //Since pagination is disabled on RSS/mastodon
            //this can result in duplicate entries when parsing
            //thumbnails causing extra uneccessary load
            let uniqueResults: [Model]
            if force {
                if results.isNotEmpty {
                    //covering forced fetches that dont clean
                    //i.e. a refresh
                    self?.clear(dontClean: true)
                }
                uniqueResults = results
            } else {
                uniqueResults = results.filter { self?.itemIDs.contains($0.id) == false }
            }
            
            let models: [Model]
            
            if PagerFilter.isEnabled {
                models = uniqueResults.filter { $0.shouldHide == false }
            } else {
                models = uniqueResults
            }
            
            let extendedFilterEnabled: Bool = PagerFilter.enableForNSFWExtended
            
            guard let this = self else { return }
            
            LoomLog("🟢 Fetch succeeded | \(models.count) items", level: .debug)
            
            let thumbURLs: [(String, URL?, Bool)] = models.compactMap { ($0.id, $0.thumbURL ?? $0.postURL, $0.thumbURL != nil) }
                
            if thumbURLs.isEmpty {
                insertModels(models, force: force)
            } else {
                let count = CGFloat(thumbURLs.count)
                self?.rlProcessorTask?.cancel()
                
                /*
                 TODO: revise importance
                 
                 PROs:
                 - more options for a rich-link preview
                   - goes past og:meta headers
                   - feeds feel more "alive"
                 
                 CONs:
                 - requires main thread
                   - handled per view is horrible scrolling performance
                   - queued like this is a slow loading experience
                 
                 */
                self?.rlProcessorTask = Task(priority: .userInitiated) { [weak self] in
                    var completed: CGFloat = 0.0
                    var filterModelIDs: [String] = []
                    
                    for (id, url, isThumb) in thumbURLs {
                        guard let url else { continue }
                        
                        let time = CFAbsoluteTimeGetCurrent()
                        
                        let urlRequest: URLRequest?
                        
                        if isThumb {
                            urlRequest = .init(url: url, timeoutInterval: PageableMetadata.fetchTimeout)
                        } else {
                            urlRequest = nil
                        }
                        
                        if let urlRequest,
                           let (data, _) = try? await URLSession.shared.data(for: urlRequest),
                           let image = GraniteImage(data: data) {
                            
                            this.itemMetadatas[id] = .init(linkMeta: nil, imageThumb: image)
                        } else {
                            this.itemMetadatas[id] = await this.getLPMetadata(url: url)
                        }
                        
                        if let metadata = this.itemMetadatas[id] {
                            LoomLog("Rich Link Data received: \(CFAbsoluteTimeGetCurrent() - time) - isThumb: \(isThumb)", level: .info)
                            
                            if let image = metadata.imageThumb,
                               extendedFilterEnabled {
                                let isNSFW = await ModerationKit.current.check(image, for: .nsfw)
                                
                                if isNSFW {
                                    filterModelIDs.append(id)
                                }
                            }
                        } else {
                            LoomLog("Rich Link Data failed/timed out \(CFAbsoluteTimeGetCurrent() - time) - isThumb: \(isThumb)", level: .info)
                        }
                        
                        completed += 1
                        
                        let progress = completed / count
                        DispatchQueue.main.async { [weak self] in
                            self?.progressHandler?(progress)
                        }
                    }
                    
                    this.insertModels(models.filter { filterModelIDs.contains($0.id) == false }, force: force)
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
                    self?.hasMore = false
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
                
                #if os(macOS)
                self?.lastItemIds = models.map { $0.id }
                #endif
                
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
        provider.timeout = PageableMetadata.fetchTimeout
        
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
    func add(_ items: [Model], pageIndex: Int? = nil, initialFetch: Bool = true) {
        itemIDs = items.map { $0.id }
        for item in items {
            itemMap[item.id] = item
            blockedItemMap[item.id] = item.blocked
        }
        lastItem = items.last ?? lastItem
        self.initialFetch = initialFetch
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
    
    func updateBlockFromPerson(item: FederatedPerson) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            #if os(macOS)
            self?.shouldReset += 1
            #endif
            self?.clear()
            self?.resetHandler?()
            self?.fetch()
        }
    }
    
    func update() {
        #if os(macOS)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentItems = self.items
            self.currentLastItems = self.lastItems
            self.currentItemsHandler?(self.currentItems)
            self.clean()
        }
        #else
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentItems = self.items
            self.currentItemsHandler?(self.currentItems)
            self.clean()
        }
        #endif
    }
    
    func clear(dontClean: Bool = false) {
        if dontClean == false {
            self.clean()
        }
        self.pageIndex = 1
        self.hasMore = isStatic == false
        self.lastItem = nil
        self.itemIDs = []
        self.itemMap = [:]
        self.blockedItemMap = [:]
        self.currentItems = []
        self.itemMetadatas = [:]
    }
    
    func tryAgain() {
        clean()
        self.hasMore = true
        
        DispatchQueue.main.async { [weak self] in
            self?.fetch()
        }
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
