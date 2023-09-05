//
//  HeaderView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import Combine
import FederationKit

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
        case post(FederatedPostResource)
        case local
        case noBadge
        case none
    }
    
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    
    @Relay var layout: LayoutService
    
    @GraniteAction<FederatedCommunity> var viewCommunity
    @GraniteAction<String> var tappedDetail
    @GraniteAction<String> var tappedCrumb
    @GraniteAction<Void> var edit
    @GraniteAction<Void> var goToThread
    
    @State var postView: FederatedPostResource? = nil
    
    var shouldRouteCommunity: Bool = false
    var shouldRoutePost: Bool = false
    
    let showPostActions: Bool
    
    var avatarBorderColor: Color {
        if context.isPostAdmin || context.isCommentAdmin {
            return .red.opacity(0.8)
        } else if context.isOP {
            return .blue.opacity(0.8)
        } else {
            return .clear
        }
    }
    
    //Not used currently
    let badge: Badge
    
    typealias Crumb = (String, FederatedPerson)
    let crumbs: [Crumb]
    
    init(crumbs: [FederatedCommentResource] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         showPostActions: Bool = true,
         badge: Badge? = nil) {
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.showPostActions = showPostActions
        
        self.badge = badge ?? .none
    }
    
    var body: some View {
        Group {
            switch context.feedStyle {
            case .style3:
                style3View
            default:
                defaultView
            }
        }
    }
    
    func crumbColor(_ model: FederatedPerson) -> Color {
        if context.postModel?.creator.equals(model) == true {
            return .blue.opacity(0.8)
        } else if model.admin {
            return .red.opacity(0.8)
        } else {
            return .clear
        }
    }
    
    //TODO: duplicate with HeaderCardView, make reusable
    func fetchFederatedPostResource() {
        if let postView {
            self.route(postView)
            return
        }
        
        let post = context.commentModel?.post ?? context.postModel?.post
        guard let post else { return }
        
        Task.detached { @MainActor in
            guard let postView = await ContentUpdater.fetchFederatedPostResource(post) else {
                return
            }
            
            DispatchQueue.main.async {
                self.route(postView)
            }
        }
    }
    
    @MainActor
    func route(_ postView: FederatedPostResource) {
        if Device.isExpandedLayout {
            self.layout._state.feedContext.wrappedValue = .viewPost(postView)
        } else {
            self.postView = postView
            
            router.push(style: .customTrailing(Color.background)) {
                PostDisplayView(updatedModel: postView)
                    .contentContext(.withPostModel(postView, context))
            }
        }
    }
}

extension HeaderView {
    var style3View: some View {
        VStack {
            HStack {
                HStack {
                    HStack(spacing: .layer2) {
                        AvatarView(context.postModel?.community.iconURL,
                                   size: .mini,
                                   isCommunity: true)
                        
                        Text("\(context.postModel?.community.displayName ?? "")")
                            .font(.footnote)
                    }
                    .routeIf(context.postModel?.community != nil) {
                        Feed(context.postModel?.community)
                    } with: { router }
                    
                    
                    HStack(alignment: .bottom, spacing: .layer1) {
                        
                        if let time = context.display.author.time {
                            Text("•")
                                .font(.footnote)
                                .padding(.trailing, .layer1)
                                .foregroundColor(Color.foreground.opacity(0.5))
                            
                            if context.isEdited {
                                //TODO: localize
                                Text("edited")
                                    .font(.caption2.italic())
                                    .foregroundColor(.foreground.opacity(0.5))
                            }
                            
                            Text(time.timeAgoDisplay())
                                .font(.caption)
                                .foregroundColor(.foreground.opacity(0.5))
                        }
                    }
                    .frame(height: AvatarView.Size.mini.frame)
                }
                .scrollOnOverflow()
                .frame(height: AvatarView.Size.mini.frame)
                
                Spacer()
                
                if showPostActions {
                    PostActionsView(enableCommunityRoute: shouldRouteCommunity,
                                    shouldRouteToPost: shouldRoutePost,
                                    community: shouldRouteCommunity ? context.community : nil,
                                    postView: shouldRoutePost ? context.postModel : nil,
                                    person: context.person,
                                    bookmarkKind: context.bookmarkKind)
                    .attach(viewCommunity, at: \.viewCommunity)
                    .attach({
                        self.fetchFederatedPostResource()
                    }, at: \.goToPost)
                    .attach(goToThread, at: \.goToThread)
                    .attach(edit, at: \.edit)
                }
            }
        }
    }
    
    var defaultView: some View {
        HStack(spacing: .layer2) {
            
            if crumbs.isNotEmpty {
                ScrollView([.horizontal], showsIndicators: false) {
                    LazyHStack(spacing: .layer2) {
                        ForEach(crumbs, id: \.0) { crumb in
                            HStack(spacing: .layer2) {
                                AvatarView(URL(string: crumb.1.avatar ?? ""))
                                    .overlay(Circle()
                                        .stroke(crumbColor(crumb.1), lineWidth: 1.0))
                                    .padding(.horizontal, 1)
                                Text(crumb.1.name)
                                    .font(.headline)
                                    .lineLimit(1)
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
                            AvatarView(context.person?.avatarURL)
                                .overlay(Circle()
                                    .stroke(avatarBorderColor, lineWidth: 1.0))
                            
                            Text(context.display.author.headline)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            
                            guard let id = context.commentModel?.comment.id else {
                                return
                            }
                            GraniteHaptic.light.invoke()
                            tappedCrumb.perform(id)
                        }
                    }
                }
                .frame(maxHeight: AvatarView.Size.small.frame + 2)
            } else {
                AvatarView(context.person)
                    .overlay(Circle()
                        .stroke(avatarBorderColor, lineWidth: 1.0))
                    .padding(1)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(context.display.author.headline)
                        .font(.headline)
                        .lineLimit(1)
                    if let subheadline = context.display.author.subheadline {
                        Text("@"+subheadline)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                }
            }
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: .layer1) {
                if context.isEdited {
                    //TODO: localize
                    Text("edited")
                        .font(.caption2.italic())
                        .foregroundColor(.foreground.opacity(0.5))
                }
                
                if let time = context.display.author.time {
                    Text(time.timeAgoDisplay())
                        .font(.subheadline)
                        .foregroundColor(.foreground.opacity(0.5))
                }
            }
            
            if showPostActions {
                PostActionsView(enableCommunityRoute: shouldRouteCommunity,
                                shouldRouteToPost: shouldRoutePost,
                                community: shouldRouteCommunity ? context.community : nil,
                                postView: shouldRoutePost ? context.postModel : nil,
                                person: context.person,
                                bookmarkKind: context.bookmarkKind)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .attach({
                    self.fetchFederatedPostResource()
                }, at: \.goToPost)
                .attach({
                    goToThread.perform()
                }, at: \.goToThread)
                .attach({
                    edit.perform()
                }, at: \.edit)
            }
        }
        .frame(minHeight: AvatarView.Size.small.frame)
    }
}

