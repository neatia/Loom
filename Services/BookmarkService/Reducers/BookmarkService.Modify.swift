//
//  File.swift
//  Loom
//
//  Created by PEXAVC on 7/14/23.
//

import Foundation
import Granite
import SwiftUI


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
            
            let key: BookmarkKey = .current ?? .local
            
            switch meta.kind {
            case .post(let model):
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkPost: BookmarkPosts
                
                if let posts = state.posts[key]?[domain] {
                    bookmarkPost = posts
                } else {
                    bookmarkPost = .init(domain)
                }
                
                if meta.remove {
                    bookmarkPost.map[model.id] = nil
                } else {
                    bookmarkPost.map[model.id] = model
                }
                
                //state update
                if state.posts[key] == nil {
                    state.posts[key] = [:]
                }
                
                state.posts[key]?[domain] = bookmarkPost
                
                state.postDomains.insert(domain)
                state.datesPosts[domain+model.id] = .init()
            case .comment(let model, let postView):
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkComment: BookmarkComments
                
                if let comments = state.comments[key]?[domain] {
                    bookmarkComment = comments
                } else {
                    bookmarkComment = .init(domain)
                }
                
                if meta.remove {
                    bookmarkComment.map[model.id] = nil
                } else {
                    bookmarkComment.map[model.id] = model
                }
                
                bookmarkComment.postMap[model.post.id] = postView
                
                //state update
                if state.comments[key] == nil {
                    state.comments[key] = [:]
                }
                
                state.comments[key]?[domain] = bookmarkComment
                
                state.commentDomains.insert(domain)
                state.datesComments[domain+model.id] = .init()
            }
            
            state.lastUpdate = .init()
        }
    }
}
