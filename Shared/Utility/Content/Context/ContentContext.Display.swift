//
//  ContentContext.Display.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import FederationKit

extension ContentContext {
    var feedStyle: FeedStyle {
        switch viewingContext {
        case .search:
            return .style1
        default:
            if isPost {
                switch postModel?.post.instanceType {
                case .rss:
                    return .style3
                default:
                    return preferredFeedStyle
                }
            } else {
                return preferredFeedStyle
            }
        }
    }
    
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
    
    var isEdited: Bool {
        updatedTime != nil
    }
    
    var time: Date? {
        updatedTime ?? publishedTime
    }
    
    var publishedTime: Date? {
        commentModel?.counts.published.serverTimeAsDate ?? postModel?.counts.published.serverTimeAsDate
    }
    
    var updatedTime: Date? {
        if isComment {
            return commentModel?.comment.updated?.serverTimeAsDate
        } else {
            return postModel?.post.updated?.serverTimeAsDate
        }
    }
    
    var timeAbbreviated: String? {
        time?.timeAgoDisplay()
    }
    
    var viewingContextHost: String {
        if viewingContext.isBookmark {
            return viewingContext.bookmarkLocation.host ?? FederationKit.host
        } else {
            return FederationKit.host
        }
    }
    
    var hasBody: Bool {
        postModel?.post.body != nil
    }
    
    var hasURL: Bool {
        postModel?.postURL != nil
    }
    
    var hasThumb: Bool {
        postModel?.thumbURL != nil
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
                    return model.comment.local && context.isScreenshot == false ? nil : model.creator.domain
                } else {
                    return context.postModel?.post.local == true && context.isScreenshot == false ? nil : context.postModel?.creator.domain
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
