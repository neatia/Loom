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
import LemmyKit

struct PostActionsView: View {
    @GraniteAction<Community> var viewCommunity
    @GraniteAction<Void> var goToPost
    @GraniteAction<Void> var edit
    
    @GraniteAction<ContentInteraction.Kind> var interact
    //A view needs updating outside of this view's potential hierarchy
    @Environment(\.graniteEvent) var accountInteract
    
    @Environment(\.graniteRouter) var router
    @Environment(\.contentContext) var context
    
    @Environment(\.pagerMetadata) var metadata
    
    var enableCommunityRoute: Bool
    var shouldRouteToPost: Bool = true
    
    var community: Community?
    var postView: PostView?
    
    var person: Person?
    
    var bookmarkKind: BookmarkService.Kind?
    
    var isCompact: Bool = false
    
    @Relay var bookmark: BookmarkService
    @Relay var config: ConfigService
    @Relay var content: ContentService
    
    var modelIsRemoved: Bool {
        switch bookmarkKind {
        case .post(let postView):
            return postView.post.removed
        case .comment(let commentView, _):
            return commentView.comment.removed
        default:
            return false
        }
    }
    
    var body: some View {
        Menu {
            if let name = community?.name {
                Button {
                    GraniteHaptic.light.invoke()
                    
                    let community: Community? = community ?? postView?.community
                    
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
            
            if shouldRouteToPost {
                Button {
                    GraniteHaptic.light.invoke()
                    goToPost.perform()
                } label: {
                    Text("POST_ACTIONS_GO_TO_POST")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if community != nil || postView != nil {
                Divider()
            }
            
            if person?.isMe == false,
               let bookmarkKind {
                Button {
                    GraniteHaptic.light.invoke()
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
            
            if person?.isMe == true {
                Divider()
                
                Button {
                    GraniteHaptic.light.invoke()
                    edit.perform()
                } label: {
                    Text("MISC_EDIT")
                    Image(systemName: "square.and.pencil")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            if person?.isMe == true {
                Button(role: modelIsRemoved ? .none : .destructive) {
                    GraniteHaptic.light.invoke()
                    switch bookmarkKind {
                    case .post(let postView):
                        interact.perform(.removePost(postView))
                    case .comment(let commentView, _):
                        LoomLog("removing comment \(accountInteract == nil)")
                        accountInteract?
                            .send(AccountService
                                .Interact
                                .Meta(intent: .removeComment(commentView)))
                    default:
                        break
                    }
                } label: {
                    if modelIsRemoved {
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
