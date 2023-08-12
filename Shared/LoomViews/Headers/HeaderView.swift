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

class Colors {
    static var map: [String: Color] = [:]
    
    static func update(_ value: String) {
        guard map[value] == nil else {
            return
        }
        map[value] = .random
    }
}

struct HeaderView: View {
    enum Badge {
        case community(String)
        case host(String)
        case post(PostView)
        case local
        case noBadge
        case none
    }
    
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
    
    let headline: String
    let subheadline: String?
    let subtitle: String?
    let badge: Badge
    let avatarURL: URL?
    let time: Date?
    let showPostActions: Bool
    
    let id: Int
    let community: Community?
    let person: Person?
    let postView: PostView?
    let commentView: CommentView?
    
    var isAdmin: Bool {
        postView?.creator.admin == true && commentView == nil
    }
    
    var isOP: Bool {
        guard let poster = postView?.creator else {
            return false
        }
        
        return commentView?.creator.equals(poster) == true
    }
    
    var avatarBorderColor: Color {
        if isAdmin {
            return .red.opacity(0.8)
        } else if isOP {
            return .blue.opacity(0.8)
        } else {
            return .clear
        }
    }
    
    typealias Crumb = (Int, Person)
    let crumbs: [Crumb]
    
    init(_ model: PostView,
         crumbs: [PostView] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         showPostActions: Bool = true,
         badge: Badge? = nil) {
        self.headline = model.creator.name
        self.subheadline = model.post.local ? nil : model.creator.domain
        self.subtitle = nil
        
        self.avatarURL = model.avatarURL
        self.id = model.post.id
        self.community = model.community
        self.crumbs = []
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.person = model.creator
        
        self.showPostActions = showPostActions
        
        self.postView = model
        self.commentView = nil
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.badge = badge ?? .community(model.community.name)
        Colors.update(model.community.name)
    }
    
    init(_ model: CommentView,
         postView: PostView? = nil,
         crumbs: [CommentView] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         showPostActions: Bool = true,
         badge: Badge? = nil) {
        self.headline = model.creator.name
        self.subheadline = model.comment.local ? nil : model.creator.domain
        self.subtitle = nil
        
        self.avatarURL = model.avatarURL
        self.id = model.comment.id
        self.community = model.community
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.commentView = model
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.person = model.creator
        
        self.postView = postView
        
        self.showPostActions = showPostActions
        
        self.badge = badge ?? .none//((model.creator.domain != nil && model.creator.local == false) ? .host(model.creator.domain!) : .none)//.community(model.community.name)
        //Colors.update(model.creator.domain ?? model.community.name)
        
//        switch badge {
//        case .post(let postView):
//            self.postView = postView
//        default:
//            self.postView = nil
//        }
    }
    
    var body: some View {
        HStack(spacing: .layer2) {
            
            if crumbs.isNotEmpty {
                ScrollView([.horizontal], showsIndicators: false) {
                    LazyHStack(spacing: .layer2) {
                        ForEach(crumbs, id: \.0) { crumb in
                            HStack(spacing: .layer2) {
                                AvatarView(URL(string: crumb.1.avatar ?? ""))
                                    .overlay(Circle()
                                        .stroke(crumbColor(crumb.1), lineWidth: 1.0))
                                Text(crumb.1.name)
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                                    .font(.headline.bold())
                            }
                            .onTapGesture {
                                guard crumbs.first?.0 != crumb.0 else {
                                    return
                                }
                                
                                GraniteHaptic.light.invoke()
                                tappedCrumb.perform(crumb.0)
                            }
                        }
                        
                        HStack(spacing: .layer2) {
                            AvatarView(avatarURL)
                                .overlay(Circle()
                                    .stroke(avatarBorderColor, lineWidth: 1.0))
                            
                            Text(headline)
                                .font(.headline)
                        }
                        .onTapGesture {
                            GraniteHaptic.light.invoke()
                            tappedCrumb.perform(id)
                        }
                    }
                }
                .frame(maxHeight: 36)
            } else {
                AvatarView(person)
                    .overlay(Circle()
                        .stroke(avatarBorderColor, lineWidth: 1.0)
                        .foregroundColor(avatarBorderColor))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(headline)
                        .font(.headline)
                    if let subheadline {
                        Text("@"+subheadline)
                            .font(.caption2)
                    }
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
            
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.foreground)
            } else if let time {
                Text(time.timeAgoDisplay())
                    .font(.subheadline)
                    .foregroundColor(.foreground.opacity(0.5))
            }
            
            if showPostActions {
                PostActionsView(enableCommunityRoute: shouldRouteCommunity ? $enableRoute : .constant(false),
                                enablePostRoute: shouldRoutePost ? $enablePostViewRoute : .constant(false),
                                community: shouldRouteCommunity ? community : nil,
                                postView: shouldRoutePost ? postView : nil,
                                person: person,
                                bookmarkKind: bookmarkKind)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
            }
        }
    }
    
    func crumbColor(_ model: Person) -> Color {
        if postView?.creator.equals(model) == true {
            return .blue.opacity(0.8)
        } else if model.admin {
            return .red.opacity(0.8)
        } else {
            return .clear
        }
    }
}

