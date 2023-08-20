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
    @GraniteAction<Void> var share
    @Environment(\.graniteEvent) var interact
    
    @Binding var enableCommunityRoute: Bool
    
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
                    if Device.isExpandedLayout {
                        let community: Community? = community ?? postView?.community
                        
                        guard let community else { return }
                        
                        viewCommunity.perform(community)
                    } else {
                        enableCommunityRoute = true
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
                switch bookmarkKind {
                case .post(let postView):
                    share.perform()
                case .comment(let commentView, _):
                    ModalService.share(urlString: commentView.comment.ap_id)
                default:
                    break
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
                        interact?
                            .send(AccountService
                                .Interact
                                .Meta(intent: .removePost(postView)))
                    case .comment(let commentView, _):
                        interact?
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
                            interact?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPersonFromPost(postView)))
                        case .comment(let commentView, _):
                            interact?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPersonFromComment(commentView)))
                        default:
                            interact?
                                .send(AccountService
                                    .Interact
                                    .Meta(intent: .blockPerson(person)))
                        }
                    } label: {
                        Text("MISC_BLOCK".localized("@"+person.name, formatted: true))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                    switch bookmarkKind {
                    case .post(let postView):
                        interact?
                            .send(AccountService.Interact.Meta(intent: .reportPost(postView)))
                    case .comment(let commentView, _):
                        interact?
                            .send(AccountService.Interact.Meta(intent: .reportComment(commentView)))
                    default:
                        break
                    }
                } label: {
                    Text("REPORT_POST")
                }
                .buttonStyle(PlainButtonStyle())
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
        .frame(width: Device.isMacOS ? 20 : 24, height: isCompact ? 12 : 24)
        //macOS bug, causes 100% CPU usage on scroll behavior
        /*
         Reproduction:
         The main feed in feed horizontal won't lag until
         post display view shows a post. the feed's scrolling
         will cause high CPU usage, even though nothing changed
         aside from an extended window, to have post display live.
         
         
         */
//        .scaleEffect(x: -1, y: 1)
        .addHaptic()
    }
}
