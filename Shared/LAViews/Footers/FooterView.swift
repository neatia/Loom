//
//  FooterView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct FooterView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    @Environment(\.pagerMetadata) var metadata
    
    @GraniteAction<Int> var showComments
    @GraniteAction<FederatedPostResource> var replyPost
    @GraniteAction<FederatedCommentResource> var replyComment
    
    @Relay var content: ContentService
    @Relay var bookmark: BookmarkService
    
    var upvoteCount: Int {
        if let commentView = context.commentModel {
            return content.state.allComments[commentView.id]?.counts.upvotes ?? commentView.counts.upvotes
        } else if let postView = context.postModel {
            return content.state.allPosts[postView.id]?.counts.upvotes ?? postView.counts.upvotes
        } else {
            return 0
        }
    }
    var immediateUpvoteCount: Int {
        upvoteCount
    }
    var downvoteCount: Int {
        if let commentView = context.commentModel {
            return content.state.allComments[commentView.id]?.counts.downvotes ?? commentView.counts.downvotes
        } else if let postView = context.postModel {
            return content.state.allPosts[postView.id]?.counts.downvotes ?? postView.counts.downvotes
        } else {
            return 0
        }
    }
    var immediateDownvoteCount: Int {
        downvoteCount
    }
    var myVote: Int {
        if let commentView = context.commentModel {
            return content.state.allComments[commentView.id]?.my_vote ?? (commentView.my_vote ?? 0)
        } else if let postView = context.postModel {
            return content.state.allPosts[postView.id]?.my_vote ?? (postView.my_vote ?? 0)
        } else {
            return 0
        }
    }
    @State var immediateUpvote: Bool = false
    @State var immediateDownvote: Bool = false
    
    var isUpvoted: Bool {
        (
            myVote == 1 || immediateUpvote
        ) && !immediateDownvote
    }
    
    var isDownvoted: Bool {
        ( myVote == -1 || immediateDownvote ) && !immediateUpvote
    }
    
    var routeTitle: String? {
        context.postModel?.post.name
    }
    
    var isBase: Bool {
        context.location == .base
    }
    
    let isHeader: Bool
    let font: Font
    let secondaryFont: Font
    var showScores: Bool
    var isComposable: Bool
    let shouldLinkToPost: Bool
    
    init(isHeader: Bool = false,
         showScores: Bool = true,
         isComposable: Bool = false,
         shouldLinkToPost: Bool = true) {
        
        self.isHeader = isHeader
        
        self.font = isHeader ? .body : .headline
        self.secondaryFont = Device.isExpandedLayout ? (isHeader ? .title : .title2) : (isHeader ? .title2 : .title3)
        
        self.showScores = showScores
        self.isComposable = isComposable
        self.shouldLinkToPost = shouldLinkToPost
    }
    
    var body: some View {
        Group {
            switch context.feedStyle {
            case .style1, .style3:
                fullInline
            case .style2:
                stacked
            }
        }
        .task {
            immediateUpvote = isUpvoted
            immediateDownvote = isDownvoted
        }
    }
}

extension FooterView {
    func modifyBookmark() {
        guard let bookmarkKind = context.bookmarkKind else { return }
        let shouldSave: Bool = bookmark.contains(bookmarkKind) == false
        let interaction: ContentService.Interact.Kind?
        
        if context.isPost, let model = context.postModel {
            interaction = shouldSave ? .savePost(model) : .unsavePost(model)
        } else if let model = context.commentModel {
            interaction = shouldSave ? .saveComment(model) : .unsaveComment(model)
        } else {
            interaction = nil
        }
        
        guard let interaction else { return }
        
        content
            .center
            .interact
            .send(
                ContentService
                    .Interact
                    .Meta(kind: interaction,
                          context: context))
        
        bookmark
            .center
            .modify
            .send(
                BookmarkService
                    .Modify
                    .Meta(kind: bookmarkKind,
                          remove: bookmark.contains(bookmarkKind)))
    }
    
    func upvote() {
        guard context.canInteract else { return }
        immediateUpvote.toggle()
        immediateDownvote = false
    }

    func downvote() {
        guard context.canInteract else { return }
        immediateDownvote.toggle()
        immediateUpvote = false
    }
}

extension FooterView {
    var stacked: some View {
        VStack(spacing: .layer3) {
            if context.viewingContext != .screenshot {
                stackedActions
            }
            
            HStack(spacing: 0) {
                switch context.postModel?.post.instanceType {
                case .rss:
                    instanceTypeView
                default:
                    votingStackedView
                    symbolsView
                }
                
                Spacer()
                
                if isComposable {
                   Button {
                       if context.isPost,
                          let postView = context.postModel {
                           
                           GraniteHaptic.light.invoke()
                           replyPost.perform(postView)
                       } else if context.isComment,
                          let commentView = context.commentModel {
                           
                           GraniteHaptic.light.invoke()
                           replyComment.perform(commentView)
                       }
                   } label: {
                       Image(systemName: "square.and.pencil")
                           .font(font)
                           .contentShape(Rectangle())
                           .foregroundColor(.foreground.opacity(0.5))
                   }
                   .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    var stackedActions: some View {
        HStack(spacing: .layer4) {
            Button {
                guard let bookmarkKind = context.bookmarkKind else { return }
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView), context: context))
                case .comment(let commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvoteComment(commentView), context: context))
                }
                
                upvote()
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.up")
                        .font(font.bold())
                }
                .foregroundColor(isUpvoted ? .orange : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                guard let bookmarkKind = context.bookmarkKind else { return }
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView), context: context))
                case .comment(let commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView), context: context))
                }
                
                downvote()
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.down")
                        .font(font.bold())
                }
                .foregroundColor(isDownvoted ? .blue : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            if context.isPost {
                HStack(spacing: .layer1) {
                    Image(systemName: "bubble.left")
                        .font(font)
                }
                .foregroundColor(.foreground)
                .routeIf(shouldLinkToPost,
                         window: .resizable(600, 500)) {
                    PostDisplayView(context: _context)
                } with : { router }
            }
            
            if let bookmarkKind = context.bookmarkKind,
               isHeader == false || bookmarkKind.isComment == true || Device.isMacOS == false {
                Button {
                    GraniteHaptic.light.invoke()
                    modifyBookmark()
                } label: {
                    
                    Image(systemName: "bookmark\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                        .font(font)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button {
                GraniteHaptic.light.invoke()
                if context.isComment {
                    ModalService
                        .shared
                        .showShareCommentModal(context.commentModel)
                } else {
                    ModalService
                        .shared
                        .showSharePostModal(context.postModel, metadata: metadata)
                }
            } label: {
                Image(systemName: "paperplane")
                    .font(font)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .frame(height: 20)
    }
    
    var votingStackedView: some View {
        HStack(spacing: 0) {
            if showScores {
                Text("\(NumberFormatter.formatAbbreviated(immediateUpvoteCount)) LABEL_UPVOTE")
                    .font(font.smaller)
                    .padding(.trailing, .layer4)
                
                Text("\(NumberFormatter.formatAbbreviated(immediateDownvoteCount)) LABEL_DOWNVOTE")
                    .font(font.smaller)
                
                Text("•")
                    .font(.footnote)
                    .padding(.horizontal, .layer2)
            }
            
            if let replyCount = context.replyCount {
                if replyCount != 1 {
                    Text("\(String(replyCount)) CONTENT_CARD_REPLIES")
                        .font(font.smaller)
                } else {
                    Text("\(String(replyCount)) CONTENT_CARD_REPLY")
                        .font(font.smaller)
                }
            } else {
                if context.commentCount != 1 {
                    Text("\(String(context.commentCount)) CONTENT_CARD_REPLIES")
                        .font(font.smaller)
                } else {
                    Text("\(String(context.commentCount)) CONTENT_CARD_REPLY")
                        .font(font.smaller)
                }
            }
        }.foregroundColor(.foreground.opacity(0.5))
    }
}

//TODO: clean up / make reusable
extension FooterView {
    var fullInline: some View {
        HStack(spacing: 0) {
            switch context.postModel?.post.instanceType {
            case .rss:
                instanceTypeView
            default:
                votingInlineView
                symbolsView
            }
            
            Spacer()
            
            if context.isPost && context.hasBody {
                Button {
                    GraniteHaptic.light.invoke()
                    ModalService.shared.expand(context.postModel)
                } label: {
                    Image(systemName: "rectangle.expand.vertical")
                        .font(font)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer3)
            }
            
            if let bookmarkKind = context.bookmarkKind,
               isHeader == false || context.isComment {
                Button {
                    GraniteHaptic.light.invoke()
                    modifyBookmark()
                } label: {
                    
                    Image(systemName: "bookmark\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                        .font(font.smaller)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer3)
                
                Button {
                    GraniteHaptic.light.invoke()
                    if context.isComment {
                        ModalService
                            .shared
                            .showShareCommentModal(context.commentModel)
                    } else {
                        ModalService
                            .shared
                            .showSharePostModal(context.postModel, metadata: metadata)
                    }
                } label : {
                    Image(systemName: "paperplane")
                        .font(font.smaller)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            } else if isComposable {
                if isComposable {
                   Button {
                       if context.isPost,
                          let postView = context.postModel {
                           LoomLog("Editing post", level: .debug)
                           GraniteHaptic.light.invoke()
                           replyPost.perform(postView)
                       } else if context.isComment,
                          let commentView = context.commentModel {
                           
                           GraniteHaptic.light.invoke()
                           replyComment.perform(commentView)
                       }
                   } label: {
                       Image(systemName: "square.and.pencil")
                           .font(font)
                           .contentShape(Rectangle())
                           .foregroundColor(.foreground)
                   }
                   .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(height: 20)
    }
    
    var votingInlineView: some View {
        Group {
            Button {
                GraniteHaptic.light.invoke()
                
                if let commentView = context.commentModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvoteComment(commentView), context: context))
                } else if let postView = context.postModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView), context: context))
                }
                
                upvote()
            } label : {
                HStack(spacing: .layer2) {
                    Image(systemName: "arrow.up")
                        .font(font.bold())
                    
                    if showScores {
                        Text("\(NumberFormatter.formatAbbreviated(immediateUpvoteCount))")
                            .font(font.smaller)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(isUpvoted ? .orange : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                
                if let commentView = context.commentModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView), context: context))
                } else if let postView = context.postModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView), context: context))
                }
                
                downvote()
            } label : {
                HStack(spacing: .layer2) {
                    Image(systemName: "arrow.down")
                        .font(font.bold())
                    
                    if showScores {
                        Text("\(NumberFormatter.formatAbbreviated(immediateDownvoteCount))")
                            .font(font.smaller)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(isDownvoted ? .blue : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            if let replyCount = context.replyCount {
                if replyCount > 0 {
                    Button {
                        if let commentView = context.commentModel {
                            GraniteHaptic.light.invoke()
                            
                            ModalService
                                .shared
                                .showThreadDrawer(commentView: commentView,
                                                  context: context)
                        }
                    } label: {
                        HStack(spacing: 0) {
                            if replyCount != 1 {
                                Text("\(String(replyCount)) CONTENT_CARD_REPLIES")
                                    .font(font)
                            } else {
                                Text("\(String(replyCount)) CONTENT_CARD_REPLY")
                                    .font(font)
                            }
                        }.contentShape(Rectangle())
                    }.buttonStyle(PlainButtonStyle())
                        .foregroundColor(.foreground)
                }
            } else {
                HStack(spacing: .layer2) {
                    Image(systemName: "bubble.left")
                        .font(font)
                    Text("\(context.commentCount) ")
                        .font(font.smaller)
                }
                .textCase(.lowercase)
                .foregroundColor(.foreground)
                .routeIf(context.isPostAvailable && shouldLinkToPost,
                         title: routeTitle ?? "",
                         window: .resizable(600, 500)) {
                    //This won't be able to pull in an edited model from the card view
                    //it should possibly forward the call instead
                    PostDisplayView(context: _context)
                } with : { router }
            }
        }
    }
}

//MARK: Symbols
extension FooterView {
    var symbolsView: some View {
        HStack(spacing: 0) {
            if FederationKit.canInteract(context.viewingContextHost) == false {
                Text("•")
                    .font(.footnote)
                    .padding(.horizontal, .layer2)
                    .foregroundColor(.foreground.opacity(0.5))
                
                Image(systemName: "globe.americas")
                    .font(.caption)
                    .foregroundColor(.foreground.opacity(0.5))
            }
            
            if context.isPost,
               let postView = context.postModel {
                
                if postView.post.featured_community {
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Image(systemName: "pin")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.8))
                }
                
                if postView.post.featured_local {
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Image(systemName: "pin")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                }
                
                if postView.post.locked {
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Image(systemName: "lock")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                }
                
                switch postView.post.instanceType {
                case .lemmy:
                    EmptyView()
                default:
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                        .foregroundColor(.foreground.opacity(0.5))
                    instanceTypeView
                }
            }
        }
    }
    
    var instanceTypeView: some View {
        Group {
            if context.isPost,
               let postView = context.postModel {
                InstanceSymbolView(postView.post.instanceType)
            }
        }
    }
}
