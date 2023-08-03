import Granite
import LemmyKit
import SwiftUI

struct Write: GraniteComponent {
    @Command var center: Center
    @Relay var modal: ModalService
    @Relay var config: ConfigService
    
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
                } else if let response = value as? Write.Create.ResponseMeta {
                    _state.createdPostView.wrappedValue = response.postView
                    _state.showPost.wrappedValue = true
                }
            }
    }
    
    var kind: Kind
    
    init(kind: Write.Kind? = nil) {
        if let kind {
            self.kind = kind
        } else {
            #if os(macOS)
            self.kind = .full
            #else
            self.kind = .compact
            #endif
        }
    }
}
