//
//  BookmarkService.Boot.swift
//  Loom
//
//  Created by PEXAVC on 8/12/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

extension BookmarkService {
    struct Boot: GraniteReducer {
        typealias Center = BookmarkService.Center
        
        func reduce(state: inout Center.State) async {
            LoomLog("📖 booting 📖", level: .debug)
            
            guard let key = BookmarkKey.current else {
                return
            }
            
            let posts = await Federation.posts(type: .all, saved_only: true)
            
            for model in posts {
                guard let domain = model.creator.domain else {
                    continue
                }
                
                var bookmarkPost: BookmarkPosts
                
                if let posts = state.posts[key]?[domain] {
                    bookmarkPost = posts
                } else {
                    bookmarkPost = .init(domain)
                    
                    if state.posts[key] == nil {
                        state.posts[key] = [:]
                    }
                }
                
                bookmarkPost.map[model.id] = model
                state.posts[key]?[domain] = bookmarkPost
                state.postDomains.insert(domain)
                state.datesPosts[domain+model.id] = .init()
            }
            
            
            LoomLog("📖 synced \(posts.count) posts 📖", level: .debug)
            
            
            let comments = await Federation.comments(type: .all, saved_only: true)
            
            for model in comments {
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkComment: BookmarkComments
                
                if let comments = state.comments[key]?[domain] {
                    bookmarkComment = comments
                } else {
                    bookmarkComment = .init(domain)
                    
                    if state.comments[key] == nil {
                        state.comments[key] = [:]
                    }
                }
                
                //state update
                if state.comments[key] == nil {
                    state.comments[key] = [:]
                }
                
                state.comments[key]?[domain] = bookmarkComment
                
                state.commentDomains.insert(domain)
                state.datesComments[domain+model.id] = .init()
            }
            
            LoomLog("📖 synced \(comments.count) comments 📖", level: .debug)
            
            
            LoomLog("📖 keys: \(Array(state.posts.keys)) 📖", level: .debug)
            
            state.lastUpdate = .init()
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
