import Granite
import LemmyKit
import SwiftUI

struct Profile: GraniteComponent {
    @Command var center: Center
    
    @Relay var modal: ModalService
    @Relay var account: AccountService
    
    @StateObject var pager: Pager<PersonDetailsPageable> = .init(emptyText: "EMPTY_STATE_MISC")
    
    var listeners: Void {
        account
            .center
            .update
            .listen { value in
                if let response = value as? AccountService.Update.ResponseMeta {
                    DispatchQueue.main.async {
                        _state.person.wrappedValue = response.person
                        modal.presentModal(GraniteToastView(response.notification))
                    }
                }
            }
    }
    
    let isMe: Bool
    
    init(_ person: Person? = nil) {
        isMe = person?.isMe == true
        _center = .init(.init(person: person ?? LemmyKit.current.user?.local_user_view.person))
    }
    
    /*
     TODO: mentions/replies
     */
}

public struct PersonDetailsPageable: Pageable {
    var date: Date {
        commentView?.date ?? postView?.date ?? .init()
    }
    
    public var id: String {
        let id = "\(commentView?.id ?? "")\(postView?.id ?? "")"
        if commentView == nil && postView == nil {
            return UUID().uuidString
        } else {
            return id
        }
    }
    
    var blocked: Bool {
        commentView?.blocked == true || postView?.blocked == true
    }
    
    var person: Person {
        (
            commentView?.creator ?? postView?.creator
        ) ?? .mock
    }
    
    let commentView: CommentView?
    let postView: PostView?
    
    var isMention: Bool
    var isReply: Bool
}
