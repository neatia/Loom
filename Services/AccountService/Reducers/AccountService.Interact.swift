//
//  AccountService.Interact.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

extension AccountService {
    struct Interact: GraniteReducer {
        typealias Center = AccountService.Center
        
        /*
         Overall the process of using a service as a proxy to provide stateful updates
         to many components for a singular action is a delicate situation.
         
         This thinking had initially lead development offstray when memory problems
         were discovered.
         
         --
         
         This leads to the favorable statically served reactions to interactions.
         See:
           1. Modals/Modals.swift
           2. ContentUpdater.swift
         
         Relays in Granite should be treated as Redis. Where core nodes are on top
         of the tree. And relays spawned in child nodes/subviews communicate changes
         upstream to the core node. Nothing comes back down stream, views only update
         on the path upwards.
         
         If network responses are required for view updates. Then the static solution
         seems to be a better solution. Especially for complex setups such as a social
         app
         
         -- UPDATE 8/25
         
         Bubbler method ~ see: CommentCardView.swift
         */
        
        enum Intent {
            case blockPerson(FederatedPerson)
            case blockPersonFromPost(FederatedPostResource)
            case blockPersonFromComment(FederatedCommentResource)
            case blockCommunity(FederatedCommunityResource)
            case reportPost(FederatedPostResource)
            case reportPostSubmit(ReportView.Submit)
            case reportComment(FederatedCommentResource)
//            case removePost(FederatedPostResource)
//            case removeComment(FederatedCommentResource)
            case deletePost(FederatedPostResource)
            case deleteComment(FederatedCommentResource)
            case subscribe(FederatedCommunityResource)
            case editPost(FederatedPostResource)
            case removeFromProfiles(FederatedPerson?)
        }
        
        struct Meta: GranitePayload {
            var intent: Intent
        }
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var intent: Intent
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            guard let intent = meta?.intent else {
                return
            }
            
            
            guard FederationKit.isAuthenticated() else {
                //TODO: localize
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "You need to login to do that",
                                      event: .error))
                
                return
            }
            
            guard FederationKit.isHome() else {
                //TODO: localize
                let host = FederationKit.host
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "You need to login into a @\(host) account to do that.",
                                      event: .error))
                
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
                
                let personBlocks = state.meta?.resource.person_blocks ?? []
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model) == true }) != nil
                
                let result = await Federation.block(person: model, block: blocked ? false : true)
                
                guard let result else { return }
                
                guard let accountMeta = state.meta else {
                    LoomLog("no account in state to update block")
                    return
                }
                
                //TODO: reuse block logics
                broadcast.send(
                    ResponseMeta(
                        notification: StandardNotificationMeta(
                            title: "MISC_SUCCESS",
                            message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person.name, formatted: true)), event: .success),
                        intent: .blockPerson(result.person)))
                
                let personView: PersonRelationshipModel = .init(person: accountMeta.person,
                                                                target: result.person)
                
                state.meta? = .init(resource: accountMeta
                    .resource
                    .updateBlocks(accountMeta.resource.person_blocks.filter {
                        $0.target.equals(result.person) == false
                        
                    } + (result.blocked ? [personView] : [])),
                                    host: accountMeta.host)
                
            case .blockPersonFromPost(let model):
                let personBlocks = state.meta?.resource.person_blocks ?? []
                
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model.creator) == true }) != nil
                
                let result = await Federation.block(person: model.creator, block: blocked ? false : true)
                
                guard let result else { return }
                
                guard let accountMeta = state.meta else {
                    LoomLog("no account in state to update block")
                    return
                }
                
                broadcast.send(
                    ResponseMeta(
                        notification: StandardNotificationMeta(
                            title: "MISC_SUCCESS",
                            message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person.name, formatted: true)), event: .success),
                        intent: .blockPersonFromPost(model.updateBlock(result.blocked,
                                                                       personView: result))
                    )
                )
                
                let personView: PersonRelationshipModel = .init(person: accountMeta.person,
                                                                target: result.person)
                
                state.meta? = .init(resource: accountMeta
                    .resource
                    .updateBlocks(
                        accountMeta
                            .resource
                            .person_blocks.filter {
                                $0.target.equals(result.person) == false
                            } + (result.blocked ? [personView] : [])),
                                    host: accountMeta.host)
            case .blockPersonFromComment(let model):
                let personBlocks = state.meta?.resource.person_blocks ?? []
                
                let blocked: Bool = personBlocks.first(where: { $0.target.equals(model.creator) == true }) != nil
                
                let result = await Federation.block(person: model.creator, block: blocked ? false : true)
                
                guard let result else { return }
                
                guard let accountMeta = state.meta else {
                    LoomLog("no account in state to update block")
                    return
                }
                
                broadcast.send(
                    ResponseMeta(
                        notification: StandardNotificationMeta(
                            title: "MISC_SUCCESS",
                            message: result.blocked ? .init("MISC_BLOCKED".localized("@"+result.person.name, formatted: true)) : .init("MISC_UNBLOCKED".localized("@"+result.person.name, formatted: true)), event: .success),
                        intent:  .blockPersonFromComment(model.updateBlock(result.blocked,
                                                                           personView: result))))
                
                let personView: PersonRelationshipModel = .init(person: accountMeta.person,
                                                                target: result.person)
                state.meta? = .init(resource: accountMeta
                    .resource
                    .updateBlocks(accountMeta.resource.person_blocks.filter {
                        $0.target.equals(result.person) == false
                    } + (result.blocked ? [personView] : [])),
                                    host: accountMeta.host)
            case .blockCommunity(let model):
                _ = Task.detached {
                    let result = await Federation.block(community: model.community, block: model.blocked == true ? false : true)
                    
                }
                
            //MARK: Community
            case .subscribe(let model):
                _ = Task.detached {
                    let result = await Federation.follow(community: model.community,
                                                         follow: model.subscribed != .notSubscribed ? false : true)
                    
                    guard let result else { return }
                    
                    switch model.subscribed {
                    case .subscribed:
                        beam.send(
                            ResponseMeta(notification: .init(title: "MISC_SUCCESS",
                                                             //TODO: localize
                                                             message: "Unsubscribed from \(model.community.title)",
                                                             event: .success),
                                         intent: .subscribe(result)))
                    case .notSubscribed:
                        beam.send(
                            ResponseMeta(notification: .init(title: "MISC_SUCCESS",
                                                             message: "ALERT_SUBSCRIBED_SUCCESS \(model.community.title)",
                                                             event: .success),
                                         intent: .subscribe(result)))
                    case .pending:
                        beam.send(
                            ResponseMeta(notification: .init(title: "MISC_SUCCESS",
                                                             //TODO: localize
                                                             message: "Cancelled subscription for \(model.community.title)",
                                                             event: .success),
                                         intent: .subscribe(result)))
                    }
                }
                
            //MARK: Remove
//            case .removePost(let model):
//                let result = await Lemmy.removePost(model.post, removed: model.post.removed == true ? false : true)
//                if let result, let meta {
//                    broadcast.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: model.post.removed ? "ALERT_POST_RESTORED_SUCCESS" : "ALERT_POST_REMOVE_SUCCESS", event: .success), intent: .removePost(result.post_view)))
//                } else {
//                    broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "ALERT_POST_FAILED_TO_REMOVE", event: .error))
//                }
//            case .removeComment(let model):
//                let result = await Lemmy.removeComment(model.comment, removed: model.comment.removed == true ? false : true)
//
//                if let result, let meta {
//                    broadcast.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: model.comment.removed ? "ALERT_COMMENT_RESTORED_SUCCESS" : "ALERT_COMMENT_REMOVE_SUCCESS", event: .success), intent: meta.intent))
//
//                } else {
//                    broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "ALERT_COMMENT_FAILED_TO_REMOVE", event: .error))
//                }
            //MARK: Delete
            case .deletePost(let model):
                let result = await Federation.deletePost(model.post,
                                                         deleted: model.post.deleted == true ? false : true)
                if let result, let meta {
                    broadcast.send(
                        ResponseMeta(notification:
                                        StandardNotificationMeta(title: "MISC_SUCCESS",
                                                                 message: model.post.deleted ? "ALERT_POST_RESTORED_SUCCESS" : "ALERT_POST_REMOVE_SUCCESS",
                                                                 event: .success),
                                     intent: .deletePost(result)))
                } else {
                    broadcast.send(
                        StandardNotificationMeta(title: "MISC_ERROR",
                                                 message: "ALERT_POST_FAILED_TO_REMOVE",
                                                 event: .error))
                }
            case .deleteComment(let model):
                let result = await Federation.deleteComment(model.comment,
                                                            deleted: model.comment.deleted == true ? false : true)
                
                if let result, let meta {
                    broadcast.send(
                        ResponseMeta(notification:
                                        StandardNotificationMeta(title: "MISC_SUCCESS",
                                                                 message: model.comment.deleted ? "ALERT_COMMENT_RESTORED_SUCCESS" : "ALERT_COMMENT_REMOVE_SUCCESS",
                                                                 event: .success),
                                     intent: .deleteComment(result)))
                    
                } else {
                    broadcast.send(
                        StandardNotificationMeta(title: "MISC_ERROR",
                                                 message: "ALERT_COMMENT_FAILED_TO_REMOVE",
                                                 event: .error))
                }
            case .reportPost:
                beam.send(meta)
            case .reportComment:
                beam.send(meta)
            case .reportPostSubmit(let form):
                let result = await Federation.report(post: form.model.post,
                                                     reason: form.reason)
                
                guard let result, let meta else {
                    broadcast.send(
                        StandardNotificationMeta(title: "MISC_ERROR",
                                                 message: "ALERT_POST_FAILED_TO_REPORT",
                                                 event: .error))
                    return
                }
                
                broadcast.send(
                    ResponseMeta(notification:
                                    StandardNotificationMeta(title: "MISC_SUCCESS",
                                                             message: "ALERT_POST_REPORT_SUCCESS",
                                                             event: .success),
                                 intent: .reportPostSubmit(.init(reason: form.reason, model: form.model))))
            case .removeFromProfiles(let person):
                guard let person else { return }
                
                state.profiles.removeAll(where: { $0.person.equals(person)})
                
                try? AccountService
                    .deleteToken(identifier: AccountService.keychainAuthToken + person.username,
                                 service: AccountService.keychainService + person.actor_id.host)
            default:
                break
            }
        }
        
        func update(_ intent: Interact.Intent) {
            
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
