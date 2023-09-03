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

struct HeaderCardView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    
    @Relay var layout: LayoutService
    
    @GraniteAction<FederatedCommunity> var viewCommunity
    @GraniteAction<Void> var tapped
    @GraniteAction<Void> var edit
    @GraniteAction<Void> var goToThread
    @GraniteAction<Void> var replyToContent
    
    @State var postView: FederatedPostResource? = nil
    
    var shouldRouteCommunity: Bool
    var shouldRoutePost: Bool
    var shouldCollapse: Bool
    
    let badge: HeaderView.Badge
    
    let isCompact: Bool
    
    typealias Crumb = (String, FederatedPerson)
    let crumbs: [Crumb]
    
    init(crumbs: [FederatedCommentResource] = [],
         shouldRouteCommunity: Bool = true,
         shouldRoutePost: Bool = true,
         shouldCollapse: Bool = false,
         badge: HeaderView.Badge? = nil,
         isCompact: Bool = false) {
        
        self.shouldRouteCommunity = shouldRouteCommunity
        self.shouldRoutePost = shouldRoutePost
        self.shouldCollapse = shouldCollapse
        
        self.badge = .noBadge
        
        self.isCompact = isCompact
        
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
    }
    
    var body: some View {
        HStack(spacing: .layer2) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(context.display.author.headline)
                        .lineLimit(1)
                        .font(isCompact ? .subheadline : .headline)
                    if let subheadline = context.display.author.subheadline {
                        Text("@"+subheadline)
                            .font(.caption2)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapped.perform()
            }
            
            switch context.viewingContext {
            case .screenshot:
                Image("logo_small")
                    .resizable()
                    .frame(width: 24, height: 24)
            default:
                HStack(alignment: .bottom, spacing: .layer1) {
                    if context.isEdited {
                        //TODO: localize
                        Text("edited")
                            .font(.caption2.italic())
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                    
                    if let time = context.timeAbbreviated {
                        Text(time)
                            .font(.footnote)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    PostActionsView(enableCommunityRoute: shouldRouteCommunity,
                                    community: shouldRouteCommunity ? context.community : nil,
                                    postView: (shouldRoutePost || !isCompact) ? postView : nil,
                                    person: context.person,
                                    bookmarkKind: context.bookmarkKind,
                                    isCompact: isCompact)
                        .attach(viewCommunity, at: \.viewCommunity)
                        .attach(fetchFederatedPostResource, at: \.goToPost)
                        .attach(goToThread, at: \.goToThread)
                        .attach(replyToContent, at: \.replyToContent)
                        .attach(edit, at: \.edit)
                }
            }
        }
        .task {
            postView = context.postModel
        }
        .offset(y: shouldCollapse ? 0 : -4)//offset
    }
    
    func fetchFederatedPostResource() {
        if let postView {
            self.route(postView)
            return
        }
        
        guard let commentView = context.commentModel else { return }
        
        Task { @MainActor in
            guard let postView = await ContentUpdater
                .fetchFederatedPostResource(commentView.post,
                                            commentModel: commentView.comment) else {
                return
            }
            
            DispatchQueue.main.async {
                self.route(postView)
            }
        }
    }
    
    func route(_ postView: FederatedPostResource) {
        if Device.isExpandedLayout {
            self.layout._state.feedContext.wrappedValue = .viewPost(postView)
        } else {
            router.push(style: .customTrailing()) {
                PostDisplayView(updatedModel: postView)
                    .contentContext(.withPostModel(postView, context))
            }
            
            self.postView = postView
        }
    }
}
