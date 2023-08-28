//
//  FooterView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI

struct FooterView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    @Environment(\.pagerMetadata) var metadata
    
    @GraniteAction<CommentId> var showComments
    @GraniteAction<PostView> var replyPost
    @GraniteAction<CommentView> var replyComment
    
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
    var downvoteCount: Int {
        if let commentView = context.commentModel {
            return content.state.allComments[commentView.id]?.counts.downvotes ?? commentView.counts.downvotes
        } else if let postView = context.postModel {
            return content.state.allPosts[postView.id]?.counts.downvotes ?? postView.counts.downvotes
        } else {
            return 0
        }
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
    
    init(isHeader: Bool = false,
         showScores: Bool = true,
         isComposable: Bool = false) {
        
        self.isHeader = isHeader
        
        self.font = isHeader ? .title3 : .headline
        self.secondaryFont = Device.isExpandedLayout ? (isHeader ? .title : .title2) : (isHeader ? .title2 : .title3)
        
        self.showScores = showScores
        self.isComposable = isComposable
    }
    
    var body: some View {
        Group {
            switch context.preferredStyle {
            case .style1:
                fullInline
            case .style2:
                stacked
            }
        }
    }
}

extension FooterView {
    func modifyBookmark() {
        guard let bookmarkKind = context.bookmarkKind else { return }
        switch bookmarkKind {
        case .post(let model):
            if bookmark.contains(bookmarkKind) {
                content.center.interact.send(ContentService.Interact.Meta(kind: .unsavePost(model)))
            } else {
                content.center.interact.send(ContentService.Interact.Meta(kind: .savePost(model)))
            }
        case .comment(let model, _):
            if bookmark.contains(bookmarkKind) {
                content.center.interact.send(ContentService.Interact.Meta(kind: .unsaveComment(model)))
            } else {
                content.center.interact.send(ContentService.Interact.Meta(kind: .saveComment(model)))
            }
        }
        bookmark.center.modify.send(BookmarkService.Modify.Meta(kind: bookmarkKind, remove: bookmark.contains(bookmarkKind)))
    }
}

extension FooterView {
    var stacked: some View {
        VStack(spacing: .layer3) {
            if context.viewingContext != .screenshot {
                stackedActions
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    if showScores {
                        Text("\(NumberFormatter.formatAbbreviated(upvoteCount)) LABEL_UPVOTE")
                            .font(font.smaller)
                            .padding(.trailing, .layer4)
                        
                        Text("\(NumberFormatter.formatAbbreviated(downvoteCount)) LABEL_DOWNVOTE")
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
                
                symbols
                
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
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView)))
                case .comment(let commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvoteComment(commentView)))
                }
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.up")
                        .font(font.bold())
                }
                .foregroundColor(myVote == 1 ? .orange : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                guard let bookmarkKind = context.bookmarkKind else { return }
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView)))
                case .comment(let commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView)))
                }
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.down")
                        .font(font.bold())
                }
                .foregroundColor(myVote == -1 ? .blue : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            if context.isPost {
                HStack(spacing: .layer1) {
                    Image(systemName: "bubble.left")
                        .font(font)
                }
                .foregroundColor(.foreground)
                .route(window: .resizable(600, 500)) {
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
}

//TODO: clean up / make reusable
extension FooterView {
    var fullInline: some View {
        HStack(spacing: 0) {
            Button {
                GraniteHaptic.light.invoke()
                
                if let commentView = context.commentModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvoteComment(commentView)))
                } else if let postView = context.postModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView)))
                }
                
            } label : {
                HStack(spacing: .layer2) {
                    Image(systemName: "arrow.up")
                        .font(font.bold())
                    
                    if showScores {
                        Text("\(upvoteCount)")
                            .font(font.smaller)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(myVote == 1 ? .orange : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                
                if let commentView = context.commentModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView)))
                } else if let postView = context.postModel {
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView)))
                }
            } label : {
                HStack(spacing: .layer2) {
                    Image(systemName: "arrow.down")
                        .font(font.bold())
                    
                    if showScores {
                        Text("\(downvoteCount)")
                            .font(font.smaller)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(myVote == -1 ? .blue : .foreground)
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
                .routeIf(context.isPostAvailable,
                         title: routeTitle ?? "",
                         window: .resizable(600, 500)) {
                    //This won't be able to pull in an edited model from the card view
                    //it should possibly forward the call instead
                    PostDisplayView(context: _context)
                } with : { router }
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
}

//MARK: Symbols
extension FooterView {
    var symbols: some View {
        HStack(spacing: 0) {
            if isBase == false {
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
                
                if postView.post.featured_community || postView.post.featured_local {
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Image(systemName: "pin")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.8))
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
            }
        }
    }
}
