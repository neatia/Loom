//
//  AccountService.Interact.swift
//  Lemur
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension AccountService {
    struct Interact: GraniteReducer {
        typealias Center = AccountService.Center
        
        enum Intent {
            case blockPerson(Person)
            case blockPersonFromPost(PostView)
            case blockPersonFromComment(CommentView)
            case blockCommunity(CommunityView)
            case updatePersonBlockStatus(BlockPersonResponse)
            case reportPost(PostView)
            case reportPostSubmit(ReportView.Submit)
            case reportComment(CommentView)
            case removePost(PostView)
            case removeComment(CommentView)
            case subscribe(CommunityView)
        }
        
        struct Meta: GranitePayload {
            var intent: Intent
        }
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var intent: Intent
        }
        
        @Payload var meta: Meta?
        
        @Event var response: InteractResponse.Reducer
        
        func reduce(state: inout Center.State) {
            guard let intent = meta?.intent else {
                return
            }
            /*
             TODO: when receiver is being monitored by 2 diff instances
             there is an issue with updating each since i remove observers
             per link
             */
            switch intent {
            //MARK: Blocks
            case .blockPerson(let model):
                
                let personBlocks = state.meta?.info.person_blocks ?? []
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model) == true }) != nil
                _ = Task.detached {
                    let result = await Lemmy.block(person: model, block: blocked ? false : true)
                    
                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta.init(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person_view.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person_view.person.name, formatted: true)), event: .success), intent: .blockPerson(result.person_view.person)))
                    
                    response.send(InteractResponse.Meta(intent: .updatePersonBlockStatus(result)))
                }
            case .blockPersonFromPost(let model):
                
                let personBlocks = state.meta?.info.person_blocks ?? []
                
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model.creator) == true }) != nil
                _ = Task.detached {
                    let result = await Lemmy.block(person: model.creator, block: blocked ? false : true)
                    
                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta.init(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person_view.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person_view.person.name, formatted: true)), event: .success), intent: .blockPersonFromPost(model.updateBlock(result.blocked, personView: result.person_view))))
                    
                    response.send(InteractResponse.Meta(intent: .updatePersonBlockStatus(result)))
                }
            case .blockPersonFromComment(let model):
                let personBlocks = state.meta?.info.person_blocks ?? []
                
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model.creator) == true }) != nil
                _ = Task.detached {
                    let result = await Lemmy.block(person: model.creator, block: blocked ? false : true)
                    
                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta.init(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person_view.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person_view.person.name, formatted: true)), event: .success), intent:  .blockPersonFromComment(model.updateBlock(result.blocked, personView: result.person_view))))
                    
                    //We send the same intent for these since we are simply updating the blocklist
                    response.send(InteractResponse.Meta(intent: .updatePersonBlockStatus(result)))
                }
            case .blockCommunity(let model):
                _ = Task.detached {
                    let result = await Lemmy.block(community: model.community, block: model.blocked == true ? false : true)
                    
                }
                
            //MARK: Community
            case .subscribe(let model):
                _ = Task.detached {
                    let result = await Lemmy.follow(community: model.community, follow: model.subscribed == .subscribed ? false : true)
                    
                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta(notification: .init(title: "MISC_SUCCESS", message: "ALERT_SUBSCRIBED_SUCCESS \(model.community.title)", event: .success), intent: .subscribe(result.community_view)))
                    
//                    response.send(InteractResponse.Meta(kind: .community(result.community_view)))
                }
                
            //MARK: Remove
            case .removePost(let model):
                _ = Task.detached {
                    let result = await Lemmy.removePost(model.post, removed: model.post.removed == true ? false : true)
                    if let result, let meta {
                        broadcast.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: model.post.removed ? "ALERT_POST_RESTORED_SUCCESS" : "ALERT_POST_REMOVE_SUCCESS", event: .success), intent: .removePost(result.post_view)))
                        
                        response.send(InteractResponse.Meta(postResponse: result, intent: .removePost(result.post_view)))
                    } else {
                        broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "ALERT_POST_FAILED_TO_REMOVE", event: .error))
                    }
                }
            case .removeComment(let model):
                _ = Task.detached {
                    let result = await Lemmy.removeComment(model.comment, removed: model.comment.removed == true ? false : true)
                    
                    if let result, let meta {
                        broadcast.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: model.comment.removed ? "ALERT_COMMENT_RESTORED_SUCCESS" : "ALERT_COMMENT_REMOVE_SUCCESS", event: .success), intent: meta.intent))
                        
                        response.send(InteractResponse.Meta(commentResponse: result, intent: meta.intent))
                    } else {
                        broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "ALERT_COMMENT_FAILED_TO_REMOVE", event: .error))
                    }
                }
            case .reportPost:
                beam.send(meta)
            case .reportComment:
                beam.send(meta)
            case .reportPostSubmit(let form):
                _ = Task.detached {
                    let result = await Lemmy.report(post: form.model.post, reason: form.reason)
                    
                    guard let result, let meta else {
                        broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "ALERT_POST_FAILED_TO_REPORT", event: .error))
                        return
                    }
                    
                    broadcast.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_POST_REPORT_SUCCESS", event: .success), intent: .reportPostSubmit(.init(reason: form.reason, model: form.model))))
                }
            default:
                break
            }
        }
    }
    
    struct InteractResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var postResponse: PostResponse?
            var commentResponse: CommentResponse?
            var intent: Interact.Intent
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
            switch meta.intent {
            case .updatePersonBlockStatus(let response):
                if let accountMeta = state.meta {
                    let personView: PersonBlockView = .init(person: accountMeta.person, target: response.person_view.person)
                    state.meta? = .init(info: accountMeta.info.updateBlocks(accountMeta.info.person_blocks.filter { $0.target.equals(response.person_view.person) == false } + (response.blocked ? [personView] : [])),
                                        host: accountMeta.host)
                }
            default:
                break
            }
        }
    }
}
