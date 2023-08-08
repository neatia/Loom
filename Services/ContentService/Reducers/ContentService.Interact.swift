//
//  ContentService.Interact.swift
//  Loom
//
//  Created by PEXAVC on 7/20/23.
//

import Foundation
import Granite
import LemmyKit

extension ContentService {
    struct Interact: GraniteReducer {
        typealias Center = ContentService.Center
        
        //TODO: remove post/remove comment
        enum Kind {
            case upvotePost(PostView)
            case downvotePost(PostView)
            case upvoteComment(CommentView)
            case downvoteComment(CommentView)
            case savePost(PostView)
            case unsavePost(PostView)
            case saveComment(CommentView)
            case unsaveComment(CommentView)
            case replyPost(PostView, String)
            case replyPostSubmit(Comment, PostView)
            case replyComment(CommentView, String)
            case replyCommentSubmit(Comment, CommentView)
        }
        
        struct Meta: GranitePayload {
            var kind: Interact.Kind
        }
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var kind: Interact.Kind
        }
        
        @Payload var meta: Meta?
        
        @Event var response: InteractResponse.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
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
                _ = Task.detached {
                    let result = await Lemmy.upvotePost(post,
                                                        score: myVote)
                    
                    guard let result else { return }
                    response.send(InteractResponse.Meta(kind: .post(result)))
                }
                
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
                _ = Task.detached {
                    let result = await Lemmy.upvotePost(post,
                                                        score: myVote)
                    
                    guard let result else { return }
                    response.send(InteractResponse.Meta(kind: .post(result)))
                }
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
                _ = Task.detached {
                    let result = await Lemmy.upvoteComment(comment,
                                                           score: myVote)
                    
                    guard let result else { return }
                    response.send(InteractResponse.Meta(kind: .comment(result)))
                }
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
                _ = Task.detached {
                    let result = await Lemmy.upvoteComment(comment,
                                                           score: myVote)
                    
                    guard let result else { return }
                    response.send(InteractResponse.Meta(kind: .comment(result)))
                }
            case .replyPost(let model, let content):
                _ = Task.detached {
                    let result = await Lemmy.createComment(content, post: model.post)

                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta(notification: .init(title: "MISC_SUCCESS", message: "ALERT_COMMENT_SUCCESS", event: .success), kind: .replyPostSubmit(result, model)))
                }
                
            case .replyComment(let model, let content):
                _ = Task.detached {
                    let result = await Lemmy.createComment(content, post: model.post, parent: model.comment)

                    guard let result else { return }
                    
                    broadcast.send(ResponseMeta(notification: .init(title: "MISC_SUCCESS", message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.person.name)", event: .success), kind: .replyCommentSubmit(result, model)))
                }
            case .savePost(let model):
                _ = Task.detached {
                    let result = await Lemmy.savePost(model.post, save: true)
                    //Toast?
                }
            case .unsavePost(let model):
                _ = Task.detached {
                    let result = await Lemmy.savePost(model.post, save: false)
                }
            case .saveComment(let model):
                _ = Task.detached {
                    let result = await Lemmy.saveComment(model.comment, save: true)
                }
            case .unsaveComment(let model):
                _ = Task.detached {
                    let result = await Lemmy.saveComment(model.comment, save: false)
                }
            default:
                break
            }
        }
    }
    
    struct InteractResponse: GraniteReducer {
        typealias Center = ContentService.Center
        
        enum Kind {
            case post(PostView)
            case comment(CommentView)
            case community(CommunityView)
        }
        
        struct Meta: GranitePayload {
            var kind: InteractResponse.Kind
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
            switch meta.kind {
            case .post(let postView):
                state.allPosts[postView.id] = postView
            case .comment(let commentView):
                state.allComments[commentView.id] = commentView
            case .community(let communityView):
                break
            default:
                break
            }
            broadcast.send(meta)
        }
    }
}
