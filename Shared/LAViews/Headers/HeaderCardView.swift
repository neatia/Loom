//
//  HeaderView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI
import Combine


struct HeaderCardView: View {
    @Environment(\.graniteEvent) var interact
    
    @Relay var layout: LayoutService
    
    @GraniteAction<Community> var viewCommunity
    @GraniteAction<Int> var tappedDetail
    @GraniteAction<Int> var tappedCrumb
    @GraniteAction<Void> var edit
    
    @State var enableRoute: Bool = false
    @State var enablePostViewRoute: Bool = false
    
    var bookmarkKind: BookmarkService.Kind? {
        if let commentView {
            return .comment(commentView, postView)
        } else if let postView {
            return .post(postView)
        }
        return nil
    }
    
    var shouldRouteCommunity: Bool = false
    var shouldRoutePost: Bool = false
    
    let person: Person?
    @State var postView: PostView?
    let commentView: CommentView?
    
    let headline: String
    let subheadline: String?
    let subtitle: String?
    let badge: HeaderView.Badge
    
    let isCompact: Bool
    
    let avatarURL: URL?
    let time: Date?
    
    let id: Int
    let community: Community?
    
    typealias Crumb = (Int, Person)
    let crumbs: [Crumb]
    
    let location: FetchType
    
    init(_ model: PostView,
         crumbs: [PostView] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         badge: HeaderView.Badge? = nil,
         isCompact: Bool = false) {
        self.headline = model.creator.name
        self.subheadline = model.post.local ? nil : model.creator.domain
        self.subtitle = nil
        self.commentView = nil
        
        self.person = model.creator
        
        self.avatarURL = model.avatarURL
        self.id = model.post.id
        self.community = model.community
        self.crumbs = []
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.badge = badge ?? .community(model.community.name)
        
        self._postView = .init(initialValue: model)
        
        self.isCompact = isCompact
        
        self.location = model.post.location ?? .base
        
        Colors.update(model.community.name)
        
    }
    
    init(_ model: CommentView,
         crumbs: [CommentView] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         badge: HeaderView.Badge? = nil,
         isCompact: Bool = false) {
        self.headline = model.creator.name
        self.subheadline = model.comment.local ? nil : model.creator.domain
        self.subtitle = nil
        self.commentView = model
        
        self.person = model.creator
        
        self.avatarURL = model.avatarURL
        self.id = model.comment.id
        self.community = model.community
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.badge = badge ?? .none
        
        self.isCompact = isCompact
        
        self.location = model.comment.location ?? .base
    }
    
    var body: some View {
        HStack(spacing: .layer2) {
            VStack(alignment: .leading, spacing: 0) {
                Text(headline)
                    .font(isCompact ? .subheadline : .headline)
                if let subheadline {
                    Text("@"+subheadline)
                        .font(.caption2)
                }
            }
            
            Spacer()
            
            if let community {
                GraniteRoute($enableRoute, window: .resizable(600, 500)) {
                    Feed(community)
                }
            }
            
            if let postView {
                GraniteRoute($enablePostViewRoute, window: .resizable(600, 500)) {
                    PostDisplayView(model: postView)
                }
            }
            
            if isCompact {
                VStack(alignment: .trailing, spacing: 0) {
                    PostActionsView(enableCommunityRoute: shouldRouteCommunity ? $enableRoute : .constant(false),
                                    community: shouldRouteCommunity ? community : nil,
                                    postView: shouldRoutePost ? postView : nil,
                                    person: person,
                                    bookmarkKind: bookmarkKind,
                                    isCompact: isCompact)
                        .attach({
                            self.fetchPostView()
                        }, at: \.goToPost)
                        .attach({
                            edit.perform()
                        }, at: \.edit)
                        .graniteEvent(interact)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.foreground)
                    } else if let time {
                        Text(time.timeAgoDisplay())
                            .font(.subheadline)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                }
            } else {
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.foreground)
                } else if let time {
                    Text(time.timeAgoDisplay())
                        .font(.subheadline)
                        .foregroundColor(.foreground.opacity(0.5))
                }
                
                PostActionsView(enableCommunityRoute: shouldRouteCommunity ? $enableRoute : .constant(false),
                                community: shouldRouteCommunity ? community : nil,
                                postView: postView,
                                person: person,
                                bookmarkKind: bookmarkKind)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .attach({
                    self.fetchPostView()
                }, at: \.goToPost)
                .attach({
                    edit.perform()
                }, at: \.edit)
                .graniteEvent(interact)
            }
        }
        .offset(y: -4)//based on badge's vertical padding + text container of header (.headline at the time)
    }
    
    func fetchPostView() {
        if let postView {
            self.route(postView)
            return
        }
        
        guard let commentView else { return }
        
        Task.detached { @MainActor in
            guard let postView = await Lemmy.post(commentView.post.id, comment: commentView.comment) else {
                return
            }
            
            self.postView = postView
            
            DispatchQueue.main.async {
                self.route(postView)
            }
        }
    }
    
    func route(_ postView: PostView) {
        if Device.isExpandedLayout {
            self.layout._state.feedContext.wrappedValue = .viewPost(postView)
        } else {
            self.postView = postView
            self.enablePostViewRoute = true
        }
    }
}
