//
//  ContentService.Interact.swift
//  Loom
//
//  Created by PEXAVC on 7/20/23.
//

import Foundation
import Granite
import FederationKit

extension ContentService {
    struct Interact: GraniteReducer {
        typealias Center = ContentService.Center
        
        //TODO: remove post/remove comment
        enum Kind {
            case upvotePost(FederatedPostResource)
            case downvotePost(FederatedPostResource)
            case upvoteComment(FederatedCommentResource)
            case downvoteComment(FederatedCommentResource)
            case savePost(FederatedPostResource)
            case unsavePost(FederatedPostResource)
            case saveComment(FederatedCommentResource)
            case unsaveComment(FederatedCommentResource)
            case replyPost(FederatedPostResource, String)
            case replyPostSubmit(FederatedComment, FederatedPostResource)
            case replyComment(FederatedCommentResource, String)
            //Target, Reply
            case replyCommentSubmit(FederatedCommentResource, FederatedCommentResource)
            case editComment(FederatedCommentResource, FederatedPostResource?)
            case editCommentSubmit(FederatedCommentResource, String)
            case editPostSubmit(FederatedPostResource)
            
            var isSaving: Bool {
                switch self {
                case .savePost,
                        .unsavePost,
                        .saveComment,
                        .unsaveComment:
                    return true
                default:
                    return false
                }
            }
        }
        
        struct Meta: GranitePayload {
            var kind: Interact.Kind
            var context: ContentContext? = nil
        }
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var kind: Interact.Kind
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            guard let meta else { return }
            
            guard FederationKit.isAuthenticated() else {
                //Saving works offline as well
                guard meta.kind.isSaving == false else { return }
                //TODO: localize
                broadcast.send(StandardErrorMeta(title: "MISC_ERROR", message: "You need to login to do that", event: .error))
                return
            }
            
            switch meta.kind {
            case .upvotePost(let postView):
                let postView = state.allPosts[postView.id] ?? postView
                
                let myVote: Int
                
                switch (postView.my_vote ?? 0) {
                case 0, -1:
                    myVote = 1
                case 1:
                    myVote = 0
                default:
                    return
                }
                
                let post = postView.post
                let result = await Federation.upvotePost(post,
                                                         score: myVote)
                
                guard let result else {
                    showNotHomeError(post.ap_id, context: meta.context)
                    return
                }
                
                state.allPosts[result.id] = result
                
            case .downvotePost(let postView):
                let postView = state.allPosts[postView.id] ?? postView
                
                let myVote: Int
                
                switch (postView.my_vote ?? 0) {
                case 0, 1:
                    myVote = -1
                case -1:
                    myVote = 0
                default:
                    return
                }
                
                let post = postView.post
                let result = await Federation.upvotePost(post,
                                                         score: myVote)
                
                guard let result else {
                    showNotHomeError(post.ap_id, context: meta.context)
                    return
                }
                
                state.allPosts[result.id] = result
            case .upvoteComment(let commentView):
                let commentView = state.allComments[commentView.id] ?? commentView
                
                let myVote: Int
                
                switch (commentView.my_vote ?? 0) {
                case 0, -1:
                    myVote = 1
                case 1:
                    myVote = 0
                default:
                    return
                }
                
                let comment = commentView.comment
                let result = await Federation.upvoteComment(comment,
                                                            score: myVote)
                
                guard let result else {
                    showNotHomeError(comment.ap_id, context: meta.context)
                    return
                }
                state.allComments[result.id] = result
            case .downvoteComment(let commentView):
                let commentView = state.allComments[commentView.id] ?? commentView
                
                let myVote: Int
                
                switch (commentView.my_vote ?? 0) {
                case 0, 1:
                    myVote = -1
                case -1:
                    myVote = 0
                default:
                    return
                }
                
                let comment = commentView.comment
                let result = await Federation.upvoteComment(comment,
                                                            score: myVote)
                
                guard let result else {
                    showNotHomeError(comment.ap_id, context: meta.context)
                    return
                }
                
                state.allComments[result.id] = result
            case .replyPost(let model, let content):
                let result = await Federation.createComment(content,
                                                            post: model.post)

                guard let result else {
                    showNotHomeError(model.post.ap_id, context: meta.context)
                    return
                }
                
                broadcast.send(
                    ResponseMeta(notification: .init(title: "MISC_SUCCESS",
                                                     message: "ALERT_COMMENT_SUCCESS",
                                                     event: .success),
                                 kind: .replyPostSubmit(result, model)))
                
            case .replyComment(let model, let content):
                let result = await Federation.createComment(content,
                                                            post: model.post,
                                                            parent: model.comment)

                guard let result else {
                    showNotHomeError(model.comment.ap_id, context: meta.context)
                    return
                }
                
                guard let user = FederationKit.user()?.resource.user.person else {
                    return
                }
                
                broadcast.send(
                    ResponseMeta(notification:
                            .init(title: "MISC_SUCCESS",
                                  message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.person.name)",
                                  event: .success),
                                 kind: .replyCommentSubmit(result.asView(with: model),
                                                           result.asView(creator: user,
                                                                         post: model.post,
                                                                         community: model.community))))
            case .savePost(let model):
                let _ = await Federation.savePost(model.post, save: true)
            case .unsavePost(let model):
                let _ = await Federation.savePost(model.post, save: false)
            case .saveComment(let model):
                let _ = await Federation.saveComment(model.comment, save: true)
            case .unsaveComment(let model):
                let _ = await Federation.saveComment(model.comment, save: false)
                
            /*
             TODO: the concept behind using reducers as proxies
             for broadcasts needs to be revised. Should they be
             handled outside, directly?
             
             */
            case .editComment:
                broadcast.send(meta)
                
            case .editCommentSubmit(let model, let content):
                guard let updatedModel = await Federation.editComment(model.comment.id,
                                                                      content: content) else {
                    showNotHomeError(model.comment.ap_id)
                    return
                }
                
                broadcast.send(Meta(kind: .editCommentSubmit(updatedModel.asView(with: model),
                                                             content)))
                
            case .editPostSubmit:
                broadcast.send(meta)
            default:
                break
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
        
        func showNotHomeError(_ actor: String? = nil, context: ContentContext? = nil) {
            let host = /*actor?.host ??*/ context?.location.host ?? FederationKit.host
            
            if FederationKit.canInteract(host) {
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "MISC_ERROR_2",
                                      event: .error))
            } else {
                //TODO: localize
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "You need to login into a @\(host) account to do that.",
                                      event: .error))
            }
        }
    }
}
