import Granite
import SwiftUI

extension Reply {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var content: String = ""
            var isReplying: Bool = false
        }
        
        @Store public var state: State
    }
    
    var postUrl: URL? {
        switch kind {
        case .replyPost(let model):
            if let thumbUrl = model.post.url,
               let url = URL(string: thumbUrl) {
                return url
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    var postOrCommentContent: String? {
        switch kind {
        case .replyComment(let model):
            return model.comment.content
        case .replyPost(let model):
            return model.post.body
        default:
            return nil
        }
    }
}
