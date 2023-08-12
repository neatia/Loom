//
//  File.swift
//  Loom
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
            
            let host = LemmyKit.host
            
            switch meta.kind {
            case .post(let model):
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkPost: BookmarkPosts
                
                if let posts = state.posts[host]?[domain] {
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
                if state.posts[host] == nil {
                    state.posts[host] = [:]
                }
                
                state.posts[host]?[domain] = bookmarkPost
                
                state.postDomains.insert(domain)
                state.datesPosts[domain+model.id] = .init()
            case .comment(let model, let postView):
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkComment: BookmarkComments
                
                if let comments = state.comments[host]?[domain] {
                    bookmarkComment = comments
                } else {
                    bookmarkComment = .init(host)
                }
                
                if meta.remove {
                    bookmarkComment.map[model.id] = nil
                } else {
                    bookmarkComment.map[model.id] = model
                }
                
                bookmarkComment.postMap[model.post.id] = postView
                
                //state update
                if state.comments[host] == nil {
                    state.comments[host] = [:]
                }
                
                state.comments[host]?[domain] = bookmarkComment
                
                state.commentDomains.insert(domain)
                state.datesComments[domain+model.id] = .init()
            }
            
            state.lastUpdate = .init()
        }
    }
}
