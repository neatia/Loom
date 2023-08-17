import Granite
import LemmyKit
import SwiftUI

struct Write: GraniteComponent {
    @Command var center: Center
    @Relay var modal: ModalService
    @Relay var config: ConfigService
    
    @GraniteAction<PostView> var updatedPost
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    enum Kind {
        case compact
        case full
        case replyPost(PostView)
        case replyComment(CommentView)
    }
    
    var listeners: Void {
        center
            .create
            .listen { value in
                if let response = value as? StandardNotificationMeta {
                    modal.presentModal(GraniteToastView(response))
                } else if let meta = value as? Write.Create.ResponseMeta {
                    updatedPost.perform(meta.postView)
                }
            }
    }
    
    var kind: Kind
    
    init(kind: Write.Kind? = nil, postView: PostView? = nil) {
        _center = .init(.init(editingPostView: postView, title: postView?.post.name ?? "", content: postView?.post.body ?? "", postURL: postView?.post.url ?? ""))
        
        if let kind {
            self.kind = kind
        } else if Device.isExpandedLayout {
            self.kind = .full
        } else {
            self.kind = .compact
        }
    }
}
