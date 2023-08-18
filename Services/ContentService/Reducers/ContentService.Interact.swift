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
            case replyCommentSubmit(CommentView, CommentView)
            case editComment(CommentView, PostView?)
            case editCommentSubmit(CommentView, String)
        }
        
        struct Meta: GranitePayload {
            var kind: Interact.Kind
        }
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var kind: Interact.Kind
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            guard let meta else { return }
            
            guard LemmyKit.auth != nil else {
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
                let result = await Lemmy.upvotePost(post,
                                                    score: myVote)
                
                guard let result else { return }
                
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
                let result = await Lemmy.upvotePost(post,
                                                    score: myVote)
                
                guard let result else { return }
                
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
                let result = await Lemmy.upvoteComment(comment,
                                                       score: myVote)
                
                guard let result else { return }
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
                let result = await Lemmy.upvoteComment(comment,
                                                       score: myVote)
                
                guard let result else { return }
                state.allComments[result.id] = result
            case .replyPost(let model, let content):
                let result = await Lemmy.createComment(content, post: model.post)

                guard let result else { return }
                
                broadcast.send(ResponseMeta(notification: .init(title: "MISC_SUCCESS", message: "ALERT_COMMENT_SUCCESS", event: .success), kind: .replyPostSubmit(result, model)))
                
            case .replyComment(let model, let content):
                let result = await Lemmy.createComment(content, post: model.post, parent: model.comment)

                guard let result else { return }
                
                broadcast.send(ResponseMeta(notification: .init(title: "MISC_SUCCESS", message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.person.name)", event: .success), kind: .replyCommentSubmit(result.asView(with: model), model)))
            case .savePost(let model):
                _ = await Lemmy.savePost(model.post, save: true)
            case .unsavePost(let model):
                _ = await Lemmy.savePost(model.post, save: false)
            case .saveComment(let model):
                _ = await Lemmy.saveComment(model.comment, save: true)
            case .unsaveComment(let model):
                _ = await Lemmy.saveComment(model.comment, save: false)
                
            /*
             TODO: the concept behind using reducers as proxies
             for broadcasts needs to be revised. Should they be
             handled outside, directly?
             
             */
            case .editComment:
                broadcast.send(meta)
                
            case .editCommentSubmit(let model, let content):
                guard let updatedModel = await Lemmy.editComment(model.comment.id, content: content) else {
                    //TODO: error  toast
                    return
                }
                broadcast.send(Meta(kind: .editCommentSubmit(updatedModel.asView(with: model), content)))
            default:
                break
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
