//
//  Context.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import SwiftUI
import LemmyKit
import Granite

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
    var postModel: PostView?
    var commentModel: CommentView?
    var feedStyle: FeedStyle = .style2
    var layoutStyle: LayoutService.Style = .compact
    var viewingContext: ViewingContext = .base
    
    var id: Int {
        (commentModel?.comment.id ?? postModel?.post.id) ?? -1
    }
    
    var community: FederatedCommunityCompact? {
        commentModel?.community ?? postModel?.community
    }
    
    var location: FetchType {
        if viewingContext.isBookmark {
            return viewingContext.bookmarkLocation
        } else {
            return (postModel?.post.location ?? commentModel?.comment.location) ?? .base
        }
    }
    
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
    
    static func addCommentModel(model: CommentView?, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: model,
                     feedStyle: context.feedStyle,
                     viewingContext: context.viewingContext)
    }
    
    static func withStyle(_ style: FeedStyle, _ context: ContentContext) -> Self {
        return .init(postModel: context.postModel,
                     commentModel: context.commentModel,
                     feedStyle: style,
                     viewingContext: context.viewingContext)
    }
}

extension ContentContext {
    var isNSFW: Bool {
        postModel?.post.nsfw == true
    }
    
    var isBot: Bool {
        postModel?.creator.bot_account == true || commentModel?.creator.bot_account == true
    }
    
    var isBlocked: Bool {
        postModel?.creator_blocked == true || commentModel?.creator_blocked == true
    }
    
    var isRemoved: Bool {
        postModel?.post.removed == true || commentModel?.comment.removed == true
    }
}

extension View {
    func contentContext(_ context: ContentContext) -> some View {
        self.environment(\.contentContext, context)
    }
}


/* FederationKit */

protocol FederatedPerson {
    var id: String { get }
    var name: String { get }
    var display_name: String? { get }
    var avatar: String? { get }
    var banned: Bool { get }
    var published: String { get }
    var updated: String? { get }
    var actor_id: String { get }
    var bio: String? { get }
    var local: Bool { get }
    var banner: String? { get }
    var deleted: Bool { get }
    var inbox_url: String? { get }
    var matrix_user_id: String? { get }
    var admin: Bool { get }
    var bot_account: Bool { get }
    var ban_expires: String? { get }
    //var instance_id: InstanceId { get }
    
    var instanceType: FederatedInstanceType { get }
}

extension FederatedPerson {
    var avatarURL: URL? {
        if let urlString = avatar {
            return URL(string: urlString)
        }
        return nil
    }
    
    var lemmy: Person? {
        self as? Person
    }
}

extension Person : FederatedPerson {
    var id: String {
        self.actor_id + self.username
    }
    
    var instanceType: FederatedInstanceType {
        .lemmy
    }
}
