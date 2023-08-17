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
    @GraniteAction<CommentId> var showComments
    @GraniteAction<PostView> var reply
    
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
    
    let isHeader: Bool
    
    let font: Font
    let secondaryFont: Font
    
    let routeTitle: String?
    
    let bookmarkKind: BookmarkService.Kind
    
    var postView: PostView?
    var commentView: CommentView?
    
    var style: FeedStyle
    
    var location: FetchType
    
    var isBase: Bool {
        location == .base
    }
    
    var showScores: Bool
    
    var isComposable: Bool
    
    init(postView: PostView?,
         commentView: CommentView?,
         isHeader: Bool = false,
         showScores: Bool = true,
         style: FeedStyle = .style1,
         isComposable: Bool = false) {
        if let commentView {
            self.commentCount = 0
            self.replyCount = commentView.replyCount
            self.bookmarkKind = .comment(commentView, postView)
            self.location = commentView.comment.location ?? .base
        } else if let postView {
            self.commentCount = postView.commentCount
            self.replyCount = nil
            self.bookmarkKind = .post(postView)
            self.location = postView.post.location ?? .base
        } else {
            fatalError("Requires either a post or comment view")
        }
        
        self.isHeader = isHeader
        
        self.font = isHeader ? .title3 : .headline
        self.secondaryFont = Device.isExpandedLayout ? (isHeader ? .title : .title2) : (isHeader ? .title2 : .title3)
        
        self.routeTitle = postView?.post.name
        self.postView = postView
        self.commentView = commentView
        
        self.style = style
        
        self.showScores = showScores
        self.isComposable = isComposable
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
    func modifyBookmark() {
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
            HStack(spacing: .layer4) {
                Button {
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
                
                if case let .post(postView) = bookmarkKind {
                    HStack(spacing: .layer1) {
                        Image(systemName: "bubble.left")
                            .font(font)
                    }
                    .foregroundColor(.foreground)
                    .route(window: .resizable(600, 500)) {
                        PostDisplayView(model: postView)
                    }
                }
                
                if isHeader == false || bookmarkKind.isComment || Device.isMacOS == false {
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
                }.foregroundColor(.foreground.opacity(0.5))
                
                symbols
                
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
                                .foregroundColor(.foreground.opacity(0.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    default:
                        EmptyView()
                    }
                }
            }
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
                switch bookmarkKind {
                case .post(let postView):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvotePost(postView)))
                case .comment(var commentView, _):
                    content.center.interact.send(ContentService.Interact.Meta(kind: .downvoteComment(commentView)))
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
                HStack(spacing: .layer2) {
                    Image(systemName: "bubble.left")
                        .font(font)
                    Text("\(commentCount) ")
                        .font(font.smaller)
                }
                .textCase(.lowercase)
                .foregroundColor(.foreground)
                .routeIf(bookmarkKind.postViewModel != nil,
                         title: routeTitle ?? "",
                         style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
                    PostDisplayView(model: bookmarkKind.postViewModel!)
                }
            }
            
            Spacer()
            
            if isHeader == false || bookmarkKind.isComment {
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
                
                Image(systemName: "paperplane")
                    .font(font.smaller)
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
            
            if commentView == nil,
               let postView,
               postView.post.featured_community || postView.post.featured_local{
                Text("•")
                    .font(.footnote)
                    .padding(.horizontal, .layer2)
                    .foregroundColor(.foreground.opacity(0.5))
                
                Image(systemName: "pin")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.8))
            }
            
            //Indicator moved to header avater
//            if postView?.creator.admin == true && commentView == nil {
//                Text("•")
//                    .font(.footnote)
//                    .padding(.horizontal, .layer2)
//                    .foregroundColor(.foreground.opacity(0.5))
//
//                Image(systemName: "a.circle")
//                    .font(.caption)
//                    .foregroundColor(.red.opacity(0.8))
//            }
            
//            if let poster = postView?.creator, commentView?.creator.equals(poster) == true {
//                Text("•")
//                    .font(.footnote)
//                    .padding(.horizontal, .layer2)
//                    .foregroundColor(.foreground.opacity(0.5))
//
//                Text("OP")
//                    .font(font.smaller)
//                    .foregroundColor(.blue.opacity(0.8))
//            }
            
            if commentView == nil,
               let postView,
               postView.post.locked {
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
