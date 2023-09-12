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
    struct Remove: GraniteReducer {
        typealias Center = BookmarkService.Center
        
        struct Meta: GranitePayload {
            var key: BookmarkKey
            var isPost: Bool
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let key = meta?.key else { return }
            
            if meta?.isPost == true {
                state.posts[key] = nil
            } else {
                state.comments[key] = nil
            }
        }
    }
    
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
                let domain = model.creator.domain ?? model.creator.actor_id
                
                guard meta.remove == false else {
                    for key in state.posts.keys {
                        if let value = state.posts[key] {
                            if let posts = value[domain] {
                                posts.map[model.id] = nil
                                state.posts[key]?[domain] = posts
                            }
                        }
                    }
                    
                    state.datesPosts[domain+model.id] = nil
                    return
                }
                
                var bookmarkPost: BookmarkPosts
                
                if let posts = state.posts[key]?[domain] {
                    bookmarkPost = posts
                } else {
                    bookmarkPost = .init(domain)
                }
                
                bookmarkPost.map[model.id] = model
                
                //state update
                if state.posts[key] == nil {
                    state.posts[key] = [:]
                }
                
                state.posts[key]?[domain] = bookmarkPost
                
                state.postDomains.insert(domain)
                state.datesPosts[domain+model.id] = .init()
            case .comment(let model, let postView):
                let domain = model.creator.domain ?? model.creator.actor_id
                
                guard meta.remove == false else {
                    for key in state.comments.keys {
                        if let value = state.comments[key] {
                            if var comments = value[domain] {
                                comments.map[model.id] = nil
                                //There could be other comments with the same post linked
                                //comments.postMap[model.post.id] = nil
                                state.comments[key]?[domain] = comments
                            }
                        }
                    }
                    
                    state.datesComments[domain+model.id] = nil
                    return
                }
                
                var bookmarkComment: BookmarkComments
                
                if let comments = state.comments[key]?[domain] {
                    bookmarkComment = comments
                } else {
                    bookmarkComment = .init(domain)
                }
                
                bookmarkComment.map[model.id] = model
                
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
