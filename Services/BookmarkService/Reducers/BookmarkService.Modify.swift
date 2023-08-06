//
//  File.swift
//  Lemur
//
//  Created by PEXAVC on 7/14/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension BookmarkService {
    struct Modify: GraniteReducer {
        typealias Center = BookmarkService.Center
        
        struct Meta: GranitePayload {
            var kind: BookmarkService.Kind
            var remove: Bool
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            switch meta.kind {
            case .post(let model):
                guard let domain = model.creator.domain else {
                    return
                }
                
                if state.posts[domain] == nil {
                    state.posts[domain] = .init(domain)
                }
                
                if meta.remove {
                    state.posts[domain]?.map[model.id] = nil
                } else {
                    state.posts[domain]?.map[model.id] = model
                }
                
                state.postDomains.insert(domain)
                
                state.posts[domain]?.ids.insert(model.id, at: 0)
            case .comment(let model, let postView):
                guard let domain = model.creator.domain else {
                    return
                }
                
                if state.comments[domain] == nil {
                    state.comments[domain] = .init(domain)
                }
                
                if meta.remove {
                    state.comments[domain]?.map[model.id] = nil
                } else {
                    state.comments[domain]?.map[model.id] = model
                }
                
                state.comments[domain]?.postMap[model.post.id] = postView
                
                state.commentDomains.insert(domain)
                
                state.comments[domain]?.ids.insert(model.id, at: 0)
            }
            
            state.lastUpdate = .init()
        }
    }
}
