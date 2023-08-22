import Granite
import LemmyKit
import SwiftUI

struct Write: GraniteComponent {
    @Command var center: Center
    @Relay var config: ConfigService
    @Relay(.silence) var content: ContentService
    
    @Relay var modal: ModalService
    
    @GraniteAction<PostView> var updatedPost
    
    static var modalId: String = "loom.write.view.sheets"
    
    enum Kind {
        case compact
        case full
        case replyPost(PostView)
        case editReplyPost(CommentView, PostView)
        case replyComment(CommentView)
        case editReplyComment(CommentView)
        
        var isEditingReply: Bool {
            switch self {
            case .editReplyPost, .editReplyComment:
                return true
            default:
                return false
            }
        }
    }
    
    var listeners: Void {
        center
            .create
            .listen { value in
                if let response = value as? StandardNotificationMeta {
                    ModalService.shared.presentModal(GraniteToastView(response))
                } else if let meta = value as? Write.Create.ResponseMeta {
                    updatedPost.perform(meta.postView)
                    content
                        .center
                        .interact
                        .send(ContentService.Interact.Meta(kind: .editPostSubmit(meta.postView)))
                }
            }
    }
    
    var kind: Kind
    
    init(kind: Write.Kind? = nil, communityView: CommunityView? = nil, postView: PostView? = nil) {
        _center = .init(.init(editingPostView: postView,
                              title: postView?.post.name ?? "",
                              content: postView?.post.body ?? "",
                              postURL: postView?.post.url ?? "",
                              postCommunity: communityView))
        
        if let kind {
            self.kind = kind
        } else if Device.isExpandedLayout {
            self.kind = .full
        } else {
            self.kind = .compact
        }
    }
}
