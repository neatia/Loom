//
//  ContentContext.Display.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/18/23.
//

import Foundation
import LemmyKit

extension ContentContext {
    var display: Display {
        .init(self)
    }
    
    var isPost: Bool {
        self.commentModel == nil && self.postModel != nil
    }
    
    var isComment: Bool {
        self.commentModel != nil
    }
    
    var isPostAvailable: Bool {
        self.postModel != nil
    }
    
    var commentCount: Int {
        postModel?.commentCount ?? 0
    }
    
    var replyCount: Int? {
        commentModel?.replyCount
    }
    
    var viewingContextHost: String {
        if viewingContext.isBookmark {
            return viewingContext.bookmarkLocation.host ?? LemmyKit.host
        } else {
            return LemmyKit.host
        }
    }
    
    var hasBody: Bool {
        postModel?.post.body != nil
    }
    
    var hasURL: Bool {
        postModel?.post.url != nil
    }
    
    struct Display {
        var author: Author
        
        var title: String
        
        init(_ context: ContentContext) {
            self.author = .init(context)
            self.title = context.postModel?.post.name ?? ""
        }
    }
}

extension ContentContext.Display {
    
    struct Author {
        var headline: String
        var subheadline: String?
        var avatarURL: URL?
        var time: Date?
        var enableRoute: Bool //?
        var person: FederatedPerson?
        
        init(_ context: ContentContext) {
            self.headline = context.person?.name ?? ""
            self.subheadline = {
                if let model = context.commentModel {
                    return model.comment.local ? nil : model.creator.domain
                } else {
                    return context.postModel?.post.local == true ? nil : context.postModel?.creator.domain
                }
            }()
            self.avatarURL = context.person?.avatarURL
            self.time = context.commentModel?.counts.published.serverTimeAsDate ??
            context.postModel?.counts.published.serverTimeAsDate
            
            self.enableRoute = context.commentModel == nil //?
            self.person = context.person
        }
    }
}

/* FederationKit */

protocol FederatedCommunityCompact {
    
}

extension FederatedCommunityCompact {
    var lemmy: Community? {
        self as? Community
    }
}

extension Community: FederatedCommunityCompact {
    
}