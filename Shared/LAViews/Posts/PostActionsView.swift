//
//  PostActionsView.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct PostActionsView: View {
    @GraniteAction<FederatedCommunity> var viewCommunity
    @GraniteAction<Void> var goToPost
    @GraniteAction<Void> var goToThread
    @GraniteAction<Void> var edit
    @GraniteAction<Void> var replyToContent
    //A view needs updating outside of this view's potential hierarchy
    @Environment(\.graniteEvent) var accountInteract
    
    @Environment(\.graniteRouter) var router
    @Environment(\.contentContext) var context
    
    @Environment(\.pagerMetadata) var metadata
    @Environment(\.openURL) var openURL
    
    var enableCommunityRoute: Bool
    var shouldRouteToPost: Bool = true
    
    var community: FederatedCommunity?
    var postView: FederatedPostResource?
    
    var person: FederatedPerson?
    
    var bookmarkKind: BookmarkService.Kind?
    
    var isCompact: Bool = false
    
    @Relay var bookmark: BookmarkService
    @Relay var config: ConfigService
    @Relay var content: ContentService
    
    var body: some View {
        Menu {
            navigationActions
            
            if community != nil || postView != nil {
                Divider()
            }
            
            interactionActions
            
            Divider()
            
            destructiveActions
                
        } label: {
            Image(systemName: "ellipsis")
                .font(Device.isExpandedLayout ? .subheadline : .footnote.bold())
                .frame(width: Device.isMacOS ? 16 : 24, height: isCompact ? 12 : 24)
                .contentShape(Rectangle())
                .foregroundColor(.foreground)
                .offset(x: Device.isMacOS ? 8 : 0)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .frame(width: Device.isMacOS ? 20 : 24, height: 12)
    }
}

extension PostActionsView {
    var interactionActions: some View {
        Group {
            if person?.isMe == false,
               let bookmarkKind {
                Button {
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
                    GraniteHaptic.light.invoke()
                    
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
                } label: {
                    Text(.init(bookmark.contains(bookmarkKind) ? "ACTIONS_REMOVE_BOOKMARK" : "MISC_BOOKMARK"))
                    Image(systemName: "bookmark\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            #if os(iOS)
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
                Text("MISC_SHARE")
                Image(systemName: "paperplane")
            }
            .buttonStyle(PlainButtonStyle())
            #endif
            
            Divider()
            
            if let postAP_id = context.postModel?.post.ap_id {
                Button {
                    GraniteHaptic.light.invoke()
                    
                    Clipboard.copyToClipboard(postAP_id)
                } label: {
                    //TODO: localize
                    Text("Copy to clipboard")
                    Image(systemName: "doc.on.clipboard")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    GraniteHaptic.light.invoke()
                    
                    guard let url = URL(string: postAP_id) else {
                        return
                    }
                    
                    openURL(url)
                } label: {
                    //TODO: localize
                    Text("Open in Safari")
                    Image(systemName: "safari")
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
            
            if person?.isMe == true {
                
                Button {
                    GraniteHaptic.light.invoke()
                    edit.perform()
                } label: {
                    Text("MISC_EDIT")
                    Image(systemName: "pencil.and.outline")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if context.isPreview == false {
                Button {
                    GraniteHaptic.light.invoke()
                    replyToContent.perform()
                } label: {
                    //TODO: localize
                    Text("Reply")
                    Image(systemName: "square.and.pencil")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    var navigationActions: some View {
        Group {
            if let name = community?.name {
                Button {
                    GraniteHaptic.light.invoke()
                    
                    let community: FederatedCommunity? = community ?? postView?.community
                    
                    guard let community else { return }
                    
                    if Device.isExpandedLayout {
                        
                        viewCommunity.perform(community)
                    } else {
                        router.push {
                            Feed(community)
                        }
                    }
                } label: {
                    Text("!\(name)")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            //TODO: context should just have the shouldRouteToPost helper condition itself
            if shouldRouteToPost && !context.viewingContext.isThread {
                Button {
                    GraniteHaptic.light.invoke()
                    goToPost.perform()
                } label: {
                    Text("POST_ACTIONS_GO_TO_POST")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if context.isComment {
                Button {
                    GraniteHaptic.light.invoke()
                    goToThread.perform()
                } label: {
                    //TODO: localize
                    Text("Go to thread")
                    Image(systemName: "scroll")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var destructiveActions: some View {
        Group {
            if person?.isMe == true {
                Button(role: context.isDeleted ? .none : .destructive) {
                    GraniteHaptic.light.invoke()
                    
                    if context.isPost,
                       let postView = context.postModel {
                        accountInteract?
                            .send(AccountService
                                .Interact
                                .Meta(intent: .deletePost(postView)))
                    } else if let commentView = context.commentModel {
                        accountInteract?
                            .send(AccountService
                                .Interact
                                .Meta(intent: .deleteComment(commentView)))
                    }
                } label: {
                    if context.isDeleted {
                        Text("MISC_RESTORE")
                        Image(systemName: "arrow.counterclockwise.circle")
                    } else {
                        Text("MISC_REMOVE")
                        Image(systemName: "trash")
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                if let person {
                    Button(role: .destructive) {
                        GraniteHaptic.light.invoke()
                        
                        switch bookmarkKind {
                        case .post(let postView):
                            accountInteract?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPersonFromPost(postView)))
                        case .comment(let commentView, _):
                            accountInteract?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPersonFromComment(commentView)))
                        default:
                            accountInteract?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPerson(person)))
                        }
                    } label: {
                        Text("MISC_BLOCK".localized("@"+person.name, formatted: true))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            
            //TODO: report functionality/testing
//                Button(role: .destructive) {
//                    GraniteHaptic.light.invoke()
//                    switch bookmarkKind {
//                    case .post(let postView):
//                        accountInteract?
//                            .send(AccountService.Interact.Meta(intent: .reportPost(postView)))
//                    case .comment(let commentView, _):
//                        accountInteract?
//                            .send(AccountService.Interact.Meta(intent: .reportComment(commentView)))
//                    default:
//                        break
//                    }
//                } label: {
//                    Text("REPORT_POST")
//                }
//                .buttonStyle(PlainButtonStyle())
        }
    }
}
