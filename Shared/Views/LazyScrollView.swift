//
//  LazyScrollView.swift
//  Loom
//
//  Created by PEXAVC on 7/27/23.
//

import Foundation
import SwiftUI
import Granite

class LazyScrollViewCache<Content: View> {
    var operationQueue: OperationQueue = .init()
    
    init() {
        operationQueue.underlyingQueue = .main
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    var viewIds: [String] = []
    var viewCache: [String : Content] = [:]
    var viewCacheSize: [String : CGSize] = [:]
    let limit: Int = 120
    let flushSize: Int = 12 //page size?
    var isFlushing: Bool = false
    
    func flush() {
        guard isFlushing == false else { return }
        isFlushing = true
        operationQueue.addOperation { [weak self] in
            guard let self else { return }
            if self.viewIds.count >= self.limit {
                let keys: [String] = Array(self.viewIds.prefix(self.flushSize))
                self.viewIds.removeFirst(self.flushSize)
                for key in keys {
                    self.viewCache[key] = nil
                    self.viewCacheSize[key] = nil
                }
                self.isFlushing = false
                print("[LazyScrollViewCache] flushed: \(self.flushSize)")
            }
        }
    }
}

struct LazyScrollView<Model: Pageable, Content: View>: View {
    
    let cache: LazyScrollViewCache<Content> = .init()
    
    let models: [Model]
    let content: (Model) -> Content
    
    init(_ models: [Model],
         @ViewBuilder content: @escaping (Model) -> Content) {
        self.models = models
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(models) { item in
                        cache(item)
                    }
                }.padding(.top, 1)
            }
        }
    }
    
    func cache(_ item: Model) -> some View {
        if let view = cache.viewCache[item.id] {
            
            return view
        }
        
        let view: Content = content(item)
        
        cache.viewCache[item.id] = view
        cache.flush()
        
        return view
    }
}
