import Granite
import LemmyKit

struct Reply: GraniteComponent {
    @Command var center: Center
    @Relay var content: ContentService
    
    @GraniteAction<(Comment, CommentView)> var updatePost
    @GraniteAction<Comment> var updateComment
    @GraniteAction<CommentView> var updateCommentView
    
    var listeners: Void {
        content
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? ContentService.Interact.ResponseMeta {
                    
                    switch response.kind {
                    case .replyPostSubmit(let comment, let model):
                        guard let user = LemmyKit.current.user?.local_user_view.person else {
                            return
                        }
                        updatePost.perform((comment, comment.asView(creator: user, postView: model)))
                    case .replyCommentSubmit(let comment, _):
                        updateComment.perform(comment)
                    default:
                        break
                    }
                } else if let response = value as? ContentService.Interact.Meta {
                    switch response.kind {
                    case .editCommentSubmit(let model, _):
                        updateCommentView.perform(model)
                    default:
                        break
                    }
                }
        }
    }
    
    
    let kind: Write.Kind
    init(kind: Write.Kind) {
        switch kind {
        case .editReplyPost(let model, _), .editReplyComment(let model):
            _center = .init(.init(content: model.comment.content))
        default:
            break
        }
        self.kind = kind
    }
}
