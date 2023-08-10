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
    
    @GraniteAction<Community> var viewCommunity
    @GraniteAction<Int> var tappedDetail
    @GraniteAction<Int> var tappedCrumb
    
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
    let postView: PostView?
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
        
        self.postView = model
        
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
        
        self.badge = badge ?? .none//((model.creator.domain != nil && model.creator.local == false) ? .host(model.creator.domain!) : .none)//.community(model.community.name)
        //Colors.update(model.creator.domain ?? model.community.name)
        
        switch badge {
        case .post(let postView):
            self.postView = postView
        default:
            self.postView = nil
        }
        
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
                                    enablePostRoute: shouldRoutePost ? $enablePostViewRoute : .constant(false),
                                    community: shouldRouteCommunity ? community : nil,
                                    postView: shouldRoutePost ? postView : nil,
                                    person: person,
                                    bookmarkKind: bookmarkKind,
                                    isCompact: isCompact)
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
                                enablePostRoute: shouldRoutePost ? $enablePostViewRoute : .constant(false),
                                community: shouldRouteCommunity ? community : nil,
                                postView: shouldRoutePost ? postView : nil,
                                person: person,
                                bookmarkKind: bookmarkKind)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .graniteEvent(interact)
            }
            
            
        }
        .offset(y: -4)//based on badge's vertical padding + text container of header (.headline at the time)
    }
}