//
//  FooterView.swift
//  Lemur
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI

struct FooterView: View {
    @GraniteAction<Void> var expand
    @GraniteAction<CommentId> var showComments
    @GraniteAction<PostView> var reply
    
    @Relay var config: ConfigService
    @Relay var content: ContentService
    @Relay var bookmark: BookmarkService
    
    var upvoteCount: Int {
        if let commentView {
            return content.state.allComments[commentView.id]?.counts.upvotes ?? commentView.counts.upvotes
        } else if let postView {
            return content.state.allPosts[postView.id]?.counts.upvotes ?? postView.counts.upvotes
        } else {
            return 0
        }
    }
    var downvoteCount: Int {
        if let commentView {
            return content.state.allComments[commentView.id]?.counts.downvotes ?? commentView.counts.downvotes
        } else if let postView {
            return content.state.allPosts[postView.id]?.counts.downvotes ?? postView.counts.downvotes
        } else {
            return 0
        }
    }
    var myVote: Int {
        if let commentView {
            return content.state.allComments[commentView.id]?.my_vote ?? (commentView.my_vote ?? 0)
        } else if let postView {
            return content.state.allPosts[postView.id]?.my_vote ?? (postView.my_vote ?? 0)
        } else {
            return 0
        }
    }
    
    let commentCount: Int
    let replyCount: Int?
    
    let font: Font
    let secondaryFont: Font
    
    let canExpand: Bool
    
    let isHeader: Bool
    
    let bookmarkKind: BookmarkService.Kind
    let routeTitle: String?
    
    var style: FeedStyle
    
    var postView: PostView?
    
    var commentView: CommentView?
    
    var isComposable: Bool = false
    
    init(_ model: PostView, isHeader: Bool = false, style: FeedStyle = .style1, isComposable: Bool = false) {
        self.commentCount = model.commentCount
        self.replyCount = nil
        self.font = isHeader ? .title3 : .headline
        self.secondaryFont = Device.isMacOS ? (isHeader ? .title : .title2) : (isHeader ? .title2 : .title3)
        self.canExpand = false
        self.bookmarkKind = .post(model)
        self.isHeader = isHeader
        self.routeTitle = model.post.name
        
        self.postView = model
        
        self.style = style
        
        self.isComposable = isComposable
        
        content.preload()
        config.preload()
    }
    
    init(_ model: CommentView, postView: PostView? = nil, isHeader: Bool = false, style: FeedStyle = .style1, isComposable: Bool = false) {
        self.commentCount = 0
        self.replyCount = model.replyCount
        self.font = isHeader ? .title3 : .headline
        self.secondaryFont = Device.isMacOS ? (isHeader ? .title : .title2) : (isHeader ? .title2 : .title3)
        self.canExpand = true
        self.bookmarkKind = .comment(model, postView)
        self.routeTitle = nil
        self.isHeader = isHeader
        
        self.postView = postView
        self.commentView = model
        
        self.style = style
        
        self.isComposable = isComposable
        
        content.preload()
        config.preload()
    }
    
    var body: some View {
        Group {
            switch style {
            case .style1:
                fullInline
            case .style2:
                stacked
            }
        }
    }
}

extension FooterView {
    var stacked: some View {
        VStack(spacing: .layer3) {
            HStack(spacing: .layer4) {
                Button {
                    GraniteHaptic.light.invoke()
                    switch bookmarkKind {
                    case .post(let postView):
                        content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView)))
                    case .comment(var commentView, _):
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
                
//                if let replyCount {
//                    if replyCount > 0 {
//                        Button {
//                            switch bookmarkKind {
//                            case .comment(let commentView, _):
//                                showComments.perform(commentView.comment.id)
//                            default:
//                                break
//                            }
//                        } label: {
//                            HStack(spacing: .layer1) {
//                                Text("\(replyCount)")
//                                    .font(font)
//                                Text("repl\(replyCount > 1 ? "ies" : "y")")
//                                    .font(font)
//                            }.contentShape(Rectangle())
//                        }.buttonStyle(PlainButtonStyle())
//                            .foregroundColor(.foreground)
//                    }
//                } else {
                if case let .post(postView) = bookmarkKind {
                    HStack(spacing: .layer1) {
                        Image(systemName: "bubble.left")
                            .font(font)
                    }
                    .foregroundColor(.foreground)
                    .route(title: routeTitle ?? "",
                           style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
                        PostDisplayView(model: postView,
                                        isFrontPage: false)
                    }
                }
                
    //            Color.clear.frame(maxWidth: .infinity)
    //                .contentShape(Rectangle())
    //                .modifier(TapAndLongPressModifier(tapAction: {  },
    //                                                  longPressAction: {
    //                    guard canExpand else { return }
    //                    GraniteHaptic.light.invoke()
    //                    expand.perform()
    //                }))
                
                if isHeader == false || bookmarkKind.isComment || Device.isMacOS == false {
                    Button {
                        GraniteHaptic.light.invoke()
                        bookmark.center.modify.send(BookmarkService.Modify.Meta(kind: bookmarkKind, remove: bookmark.contains(bookmarkKind)))
                    } label: {
                        
                        Image(systemName: "bookmark\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                            .font(font)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                #if os(iOS)
                Button {
                    GraniteHaptic.light.invoke()
                    if let commentView {
                        ModalService.share(urlString: commentView.comment.ap_id)
                    } else if let postView {
                        ModalService.share(urlString: postView.post.ap_id)
                    }
                } label: {
                    Image(systemName: "paperplane")
                        .font(font)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                #else
                Menu {
                    ForEach(NSSharingService.sharingServices(forItems: [""]), id: \.title ) { item in
                        Button(action: {
                            if let commentView {
                                var text: String = commentView.comment.content
                                text += "\n\n\(commentView.comment.ap_id)"
                                item.perform(withItems: [text])
                            } else if let postView {
                                var text: String = postView.post.name
                                if let body = postView.post.body {
                                    text += "\n\n\(body)"
                                }
                                text += "\n\n\(postView.post.ap_id)"
                                item.perform(withItems: [text])
                            }
                        }) {
                            Image(nsImage: item.image)
                            Text(item.title)
                        }
                    }
                } label: {
                    Image(systemName: "paperplane")
                        .font(font)
                        .contentShape(Rectangle())
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                #endif
                
                Spacer()
            }
            .frame(height: 20)
            
            HStack(spacing: 0) {
                if config.state.showScores {
                    Text("\(String(upvoteCount)) LABEL_UPVOTE")
                        .font(font.smaller)
                        .padding(.trailing, .layer4)
                    
                    Text("\(String(downvoteCount)) LABEL_DOWNVOTE")
                        .font(font.smaller)
                    
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer2)
                }
                
                if let replyCount {
                    if replyCount != 1 {
                        Text("\(String(replyCount)) CONTENT_CARD_REPLIES")
                            .font(font.smaller)
                    } else {
                        Text("\(String(replyCount)) CONTENT_CARD_REPLY")
                            .font(font.smaller)
                    }
                } else {
                    if commentCount != 1 {
                        Text("\(String(commentCount)) CONTENT_CARD_REPLIES")
                            .font(font.smaller)
                    } else {
                        Text("\(String(commentCount)) CONTENT_CARD_REPLY")
                            .font(font.smaller)
                    }
                }
                
                Spacer()
                
                if isComposable {
                    switch bookmarkKind {
                    case .post(let model):
                        Button {
                            GraniteHaptic.light.invoke()
                            reply.perform(model)
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(font)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    default:
                        EmptyView()
                    }
                }
            }.foregroundColor(.foreground.opacity(0.5))
        }
    }
}

//TODO: clean up / make reusable
extension FooterView {
    var fullInline: some View {
        HStack(spacing: 0) {
            Button {
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvotePost(postView)))
                case .comment(var commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .upvoteComment(commentView)))
                }
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.up")
                        .font(font.bold())
                    
                    if config.state.showScores {
                        Text("\(upvoteCount)")
                            .font(font)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(myVote == 1 ? .orange : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView)))
                case .comment(var commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView)))
                }
            } label : {
                HStack(spacing: .layer1) {
                    Image(systemName: "arrow.down")
                        .font(font.bold())
                    
                    if config.state.showScores {
                        Text("\(downvoteCount)")
                            .font(font)
                    }
                }
                .padding(.trailing, .layer4)
                .foregroundColor(myVote == -1 ? .blue : .foreground)
                .contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            if let replyCount {
                if replyCount > 0 {
                    Button {
                        switch bookmarkKind {
                        case .comment(let commentView, _):
                            showComments.perform(commentView.comment.id)
                        default:
                            break
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
                HStack(spacing: .layer1) {
                    Image(systemName: "bubble.left")
                        .font(font)
                    Text("\(commentCount)")
                        .font(font)
                }
                .foregroundColor(.foreground)
                .routeIf(bookmarkKind.postViewModel != nil,
                         title: routeTitle ?? "",
                         style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
                    PostDisplayView(model: bookmarkKind.postViewModel!,
                                    isFrontPage: false)
                }
            }
            
//            Color.clear.frame(maxWidth: .infinity)
//                .contentShape(Rectangle())
//                .modifier(TapAndLongPressModifier(tapAction: {  },
//                                                  longPressAction: {
//                    guard canExpand else { return }
//                    GraniteHaptic.light.invoke()
//                    expand.perform()
//                }))
            
            Spacer()
            
            if isHeader == false || bookmarkKind.isComment {
                Button {
                    GraniteHaptic.light.invoke()
                    bookmark.center.modify.send(BookmarkService.Modify.Meta(kind: bookmarkKind, remove: bookmark.contains(bookmarkKind)))
                } label: {
                    
                    Image(systemName: "bookmark.square\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                        .font(secondaryFont)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer2)
                
                Image(systemName: "arrow.up.square")
                    .font(secondaryFont)
            } else if isComposable,
                      bookmarkKind.isComment == false {
                switch bookmarkKind {
                case .post(let model):
                    Button {
                        GraniteHaptic.light.invoke()
                        reply.perform(model)
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(font)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                default:
                    EmptyView()
                }
            }
        }
        .frame(height: 20)
    }
}
