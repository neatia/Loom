import Granite
import LemmyKit
import SwiftUI

struct Profile: GraniteComponent {
    @Command var center: Center
    
    @Environment(\.graniteRouter) var router
    
    @Relay var account: AccountService
    @Relay var content: ContentService
    
    var pager: Pager<PersonDetailsPageable> = .init(emptyText: "EMPTY_STATE_MISC")
    
    let isMe: Bool
    
    init(_ person: Person? = nil) {
        isMe = person?.isMe == true
        _center = .init(.init(person: person ?? LemmyKit.current.user?.local_user_view.person))
        content.silence(viewUpdatesOnly: true)
    }
}

public struct PersonDetailsPageable: Pageable {
    public var date: Date {
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
    
    public var blocked: Bool {
        commentView?.blocked == true || postView?.blocked == true
    }
    
    public var person: Person {
        (
            commentView?.creator ?? postView?.creator
        ) ?? .mock
    }
    
    let commentView: CommentView?
    let postView: PostView?
    
    var isMention: Bool
    var isReply: Bool
}
