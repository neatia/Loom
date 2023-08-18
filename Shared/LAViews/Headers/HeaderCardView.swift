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
    @Environment(\.contentContext) var context
    @Environment(\.graniteEvent) var interact
    
    @Relay var layout: LayoutService
    
    @GraniteAction<Community> var viewCommunity
    @GraniteAction<Int> var tappedDetail
    @GraniteAction<Int> var tappedCrumb
    @GraniteAction<Void> var edit
    
    @State var enableRoute: Bool = false
    @State var enablePostViewRoute: Bool = false
    
    @State var postView: PostView? = nil
    
    var shouldRouteCommunity: Bool
    var shouldRoutePost: Bool
    
    let badge: HeaderView.Badge
    
    let isCompact: Bool
    
    typealias Crumb = (Int, Person)
    let crumbs: [Crumb]
    
    init(crumbs: [CommentView] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         badge: HeaderView.Badge? = nil,
         isCompact: Bool = false) {
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        
        self.badge = .noBadge
        
        self.isCompact = isCompact
        
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
    }
    
    var body: some View {
        HStack(spacing: .layer2) {
            VStack(alignment: .leading, spacing: 0) {
                Text(context.display.author.headline)
                    .font(isCompact ? .subheadline : .headline)
                if let subheadline = context.display.author.subheadline {
                    Text("@"+subheadline)
                        .font(.caption2)
                }
            }
            
            Spacer()
            
            if let community = context.community?.lemmy {
                GraniteRoute($enableRoute, window: .resizable(600, 500)) {
                    Feed(community)
                }
            }
            
            if context.isPostAvailable {
                GraniteRoute($enablePostViewRoute, window: .resizable(600, 500)) {
                    PostDisplayView()
                        .contentContext(context)
                }
            }
            
            VStack(alignment: .trailing, spacing: 0) {
                PostActionsView(enableCommunityRoute: shouldRouteCommunity ? $enableRoute : .constant(false),
                                community: shouldRouteCommunity ? context.community?.lemmy : nil,
                                postView: (shouldRoutePost || !isCompact) ? postView : nil,
                                person: context.person?.lemmy,
                                bookmarkKind: context.bookmarkKind,
                                isCompact: isCompact)
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
        .task {
            postView = context.postModel
        }
        .offset(y: -4)//based on badge's vertical padding + text container of header (.headline at the time)
    }
    
    func fetchPostView() {
        if let postView {
            self.route(postView)
            return
        }
        
        guard let commentView = context.commentModel else { return }
        
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
