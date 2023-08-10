import Granite
import SwiftUI
import LemmyKit

extension BookmarkService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var posts: [String: BookmarkPosts] = [:]
            var comments: [String: BookmarkComments] = [:]
            
            var postDomains: Set<String> = .init()
            var commentDomains: Set<String> = .init()
            
            var datesPosts: [String: Date] = [:]
            var datesComments: [String: Date] = [:]
            
            var lastUpdate: Date = .init()
        }
        
        @Event var modify: Modify.Reducer
        
        @Store(persist: "persistence.bookmark.Loom.0008", autoSave: true) public var state: State
    }
    
    func contains(_ kind: Kind) -> Bool {
        switch kind {
        case .post(let model):
            guard let domain = model.creator.domain else {
                return false
            }
            return state.posts[domain]?.map[model.id] != nil
        case .comment(let model, _):
            guard let domain = model.creator.domain else {
                return false
            }
            return state.comments[domain]?.map[model.id] != nil
        }
    }
    
    enum Kind {
        case post(PostView)
        case comment(CommentView, PostView?)
        
        var postViewModel: PostView? {
            switch self {
            case .post(let postView):
                return postView
            default:
                return nil
            }
        }
        
        var isComment: Bool {
            switch self {
            case .post:
                return false
            case .comment:
                return true
            }
        }
    }
}

class BookmarkPosts: Equatable, Codable {
    static func == (lhs: BookmarkPosts, rhs: BookmarkPosts) -> Bool {
        lhs.domain == rhs.domain && lhs.map == rhs.map
    }
    
    let domain: String
    var map: PostMap
    
    init(_ domain: String) {
        self.domain = domain
        self.map = [:]
    }
}

class BookmarkComments: Equatable, Codable {
    static func == (lhs: BookmarkComments, rhs: BookmarkComments) -> Bool {
        lhs.domain == rhs.domain && lhs.map == rhs.map
    }
    
    let domain: String
    var map: CommentMap
    var postMap: [PostId: PostView]
    
    init(_ domain: String) {
        self.domain = domain
        self.map = [:]
        self.postMap = [:]
    }
}

typealias CommentMap = [String:CommentView]
