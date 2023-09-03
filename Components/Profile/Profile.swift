import Granite
import SwiftUI
import FederationKit

struct Profile: GraniteComponent {
    @Command var center: Center
    
    @Environment(\.graniteRouter) var router
    
    @Relay var account: AccountService
    
    @StateObject var pager: Pager<PersonDetailsPageable> = .init(emptyText: "EMPTY_STATE_MISC")
    
    let isMe: Bool
    
    init(_ person: FederatedPerson? = nil, location: FederatedLocationType? = nil) {
        isMe = person?.isMe == true
        _center = .init(.init(person: person ?? FederationKit.user()?.resource.user.person, location: location))
        
        LoomLog("profile init")
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
    
    public var person: FederatedPerson {
        (
            commentView?.creator ?? postView?.creator
        ) ?? .mock
    }
    
    let commentView: FederatedCommentResource?
    let postView: FederatedPostResource?
    
    var isMention: Bool
    var isReply: Bool
}
