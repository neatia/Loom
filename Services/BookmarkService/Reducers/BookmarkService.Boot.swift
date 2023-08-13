//
//  BookmarkService.Boot.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/12/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension BookmarkService {
    struct Boot: GraniteReducer {
        typealias Center = BookmarkService.Center
        
        func reduce(state: inout Center.State) async {
            guard let key = BookmarkKey.current else {
                return
            }
            
            let posts = await Lemmy.posts(type: .all, saved_only: true)
            
            for model in posts {
                guard let domain = model.creator.domain else {
                    continue
                }
                
                var bookmarkPost: BookmarkPosts
                
                if let posts = state.posts[key]?[domain] {
                    bookmarkPost = posts
                } else {
                    bookmarkPost = .init(domain)
                }
                
                bookmarkPost.map[model.id] = model
                state.posts[key]?[domain] = bookmarkPost
                state.postDomains.insert(domain)
                state.datesPosts[domain+model.id] = .init()
            }
            
            
            let comments = await Lemmy.comments(type: .all, saved_only: true)
            
            for model in comments {
                guard let domain = model.creator.domain else {
                    return
                }
                
                var bookmarkComment: BookmarkComments
                
                if let comments = state.comments[key]?[domain] {
                    bookmarkComment = comments
                } else {
                    bookmarkComment = .init(domain)
                }
                
                //state update
                if state.comments[key] == nil {
                    state.comments[key] = [:]
                }
                
                state.comments[key]?[domain] = bookmarkComment
                
                state.commentDomains.insert(domain)
                state.datesComments[domain+model.id] = .init()
            }
            
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
