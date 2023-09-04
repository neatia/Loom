//
//  Context.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import SwiftUI
import Granite
import FederationKit

struct ContentContextKey: EnvironmentKey {
    static var defaultValue: ContentContext = .init()
}

extension EnvironmentValues {
    var contentContext: ContentContext {
        get { self[ContentContextKey.self] }
        set { self[ContentContextKey.self] = newValue }
    }
}

struct ContentContext {
    var postModel: FederatedPostResource?
    var commentModel: FederatedCommentResource?
    var preferredFeedStyle: FeedStyle = .style2
    var layoutStyle: LayoutService.Style = .compact
    var viewingContext: ViewingContext = .base
    
    var id: String {
        let contentId = (commentModel?.comment.id ?? postModel?.post.id) ?? "-1"
        return "\(viewingContext)\(contentId)"
    }
    
    var community: FederatedCommunity? {
        commentModel?.community ?? postModel?.community
    }
    
    var location: FederatedLocationType {
        switch viewingContext {
        case .bookmark, .bookmarkExpanded:
            return viewingContext.bookmarkLocation
        case .thread(let location):
            return location
        case .profile:
            return .source
        default:
            return ((customLocation) ?? .base)
        }
    }
    
    var customLocation: FederatedLocationType?
    
    var person: FederatedPerson? {
        commentModel?.creator ?? postModel?.creator
    }
    
    var isPostAdmin: Bool {
        person?.admin == true && commentModel == nil
    }
    
    var isCommentAdmin: Bool {
        commentModel?.creator.admin == true
    }
    
    var isScreenshot: Bool {
        viewingContext == .screenshot
    }
    
    var isPreview: Bool {
        viewingContext == .search
    }
    
    var isOP: Bool {
        guard let poster = postModel?.creator else {
            return false
        }
        
        return commentModel?.creator.equals(poster) == true
    }
    
    var bookmarkKind: BookmarkService.Kind? {
        if let commentModel {
            return .comment(commentModel, postModel)
        } else if let postModel {
            return .post(postModel)
        }
        return nil
    }
    
    static func addPostModel(model: FederatedPostResource?, _ context: ContentContext) -> Self {
        return .init(postModel: model ?? context.postModel,
                     commentModel: context.commentModel,
                     preferredFeedStyle: context.feedStyle,
                     viewingContext: context.viewingContext,
                     customLocation: context.customLocation)
    }
    
    static func addCommentModel(model: FederatedCommentResource?, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: model ?? context.commentModel,
                     preferredFeedStyle: context.feedStyle,
                     viewingContext: context.viewingContext,
                     customLocation: context.customLocation)
    }
    
    static func withPostModel(_ model: FederatedPostResource?, _ context: ContentContext) -> Self {
        return .init(postModel: model,
                     commentModel: nil,
                     preferredFeedStyle: context.feedStyle,
                     viewingContext: context.viewingContext,
                     customLocation: context.customLocation)
    }
    
    func withStyle(_ style: FeedStyle) -> Self {
        return .withStyle(style, self)
    }
    static func withStyle(_ style: FeedStyle, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: context.commentModel,
                     preferredFeedStyle: style,
                     viewingContext: context.viewingContext,
                     customLocation: context.customLocation)
    }
    
    func viewedIn(_ viewingContext: ViewingContext) -> ContentContext {
        return .viewedIn(viewingContext, self)
    }
    static func viewedIn(_ viewingContext: ViewingContext, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: context.commentModel,
                     preferredFeedStyle: context.feedStyle,
                     viewingContext: viewingContext,
                     customLocation: context.customLocation)
    }
    
    func updateLocation(_ customLocation: FederatedLocationType) -> Self {
        return .updateLocation(customLocation, self)
    }
    static func updateLocation(_ customLocation: FederatedLocationType, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: context.commentModel,
                     preferredFeedStyle: context.feedStyle,
                     viewingContext: context.viewingContext,
                     customLocation: customLocation)
    }
}

extension ContentContext {
    var isNSFW: Bool {
        postModel?.post.nsfw == true
    }
    
    var isBot: Bool {
        commentModel?.creator.bot_account == true || postModel?.creator.bot_account == true
    }
    
    //commentModel first, since posts come downstream with commentviews as well
    var isBlocked: Bool {
        commentModel?.creator_blocked == true || postModel?.creator_blocked == true
    }
    
    var isRemoved: Bool {
        commentModel?.comment.removed == true || postModel?.post.removed == true
    }
    
    var isDeleted: Bool {
        commentModel?.comment.deleted == true || postModel?.post.deleted == true
    }
}

extension View {
    func contentContext(_ context: ContentContext) -> some View {
        self.environment(\.contentContext, context)
    }
}
