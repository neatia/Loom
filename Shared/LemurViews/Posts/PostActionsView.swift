//
//  PostActionsView.swift
//  Lemur
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import LemmyKit

struct PostActionsView: View {
    @Environment(\.graniteEvent) var interact
    
    @Binding var enableCommunityRoute: Bool
    @Binding var enablePostRoute: Bool
    
    var community: Community?
    var postView: PostView?
    
    var person: Person?
    
    var bookmarkKind: BookmarkService.Kind?
    
    var isCompact: Bool = false
    
    @Relay var bookmark: BookmarkService
    
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
                    enableCommunityRoute = true
                } label: {
                    Text("!\(name)")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if postView != nil {
                Button {
                    GraniteHaptic.light.invoke()
                    enablePostRoute = true
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
                    bookmark.center.modify.send(BookmarkService.Modify.Meta(kind: bookmarkKind, remove: bookmark.contains(bookmarkKind)))
                } label: {
                    Text(.init(bookmark.contains(bookmarkKind) ? "ACTIONS_REMOVE_BOOKMARK" : "MISC_BOOKMARK"))
                    Image(systemName: "bookmark\(bookmark.contains(bookmarkKind) ? ".fill" : "")")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button {
                GraniteHaptic.light.invoke()
                switch bookmarkKind {
                case .post(let postView):
                    ModalService.share(urlString: postView.post.ap_id)
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
                        Text("MISC_BLOCK \("@"+person.name)")
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
                .font(Device.isMacOS ? .subheadline : .footnote.bold())
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
