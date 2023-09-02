import Granite
import SwiftUI
import FederationKit

struct Write: GraniteComponent {
    @Command var center: Center
    @Relay var config: ConfigService
    @Relay(.silence) var content: ContentService
    
    @Relay var modal: ModalService
    
    @GraniteAction<FederatedPostResource> var updatedPost
    
    @Environment(\.graniteRouter) var router
    
    static var modalId: String = "loom.write.view.sheets"
    
    enum Kind {
        case compact
        case full
        case replyPost(FederatedPostResource)
        case editReplyPost(FederatedCommentResource, FederatedPostResource)
        case replyComment(FederatedCommentResource)
        case editReplyComment(FederatedCommentResource)
        
        var isEditingReply: Bool {
            switch self {
            case .editReplyPost, .editReplyComment:
                return true
            default:
                return false
            }
        }
        
        var isPost: Bool {
            switch self {
            case .replyPost, .editReplyPost:
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
                }
            }
    }
    
    var kind: Kind
    
    init(kind: Write.Kind? = nil,
         communityView: FederatedCommunityResource? = nil,
         postView: FederatedPostResource? = nil) {
        _center = .init(.init(editingFederatedPostResource: postView,
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
