import Granite
import SwiftUI
import FederationKit

extension BookmarkService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var posts: [BookmarkKey: [String : BookmarkPosts]] = [:]
            var comments: [BookmarkKey: [String : BookmarkComments]] = [:]
            
            var postDomains: Set<String> = .init()
            var commentDomains: Set<String> = .init()
            
            var datesPosts: [String: Date] = [:]
            var datesComments: [String: Date] = [:]
            
            var lastUpdate: Date = .init()
        }
        
        @Event var boot: Boot.Reducer
        @Event var modify: Modify.Reducer
        
        @Store(persist: "persistence.bookmark.Loom.0010", autoSave: true) public var state: State
    }
    
    func contains(_ kind: Kind) -> Bool {
        let key: BookmarkKey = .current ?? .local
        
        switch kind {
        case .post(let model):
            //TODO: is using creator.domain correct here?
            guard let domain = model.creator.domain else {
                return false
            }
            
            return state.posts[key]?[domain]?.map[model.id] != nil
        case .comment(let model, _):
            guard let domain = model.creator.domain else {
                return false
            }
            return state.comments[key]?[domain]?.map[model.id] != nil
        }
    }
    
    enum Kind {
        case post(FederatedPostResource)
        case comment(FederatedCommentResource, FederatedPostResource?)
        
        var postViewModel: FederatedPostResource? {
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
    
    //PostId:
    var postMap: [String: FederatedPostResource]
    
    init(_ domain: String) {
        self.domain = domain
        self.map = [:]
        self.postMap = [:]
    }
}

struct BookmarkKey: GraniteModel, CustomStringConvertible, Hashable, Identifiable {
    let host: String
    let name: String
    
    var isLocal: Bool = false
    
    var description: String {
        if isLocal {
            return host
        } else {
            return name+"@"+host
        }
    }
    
    var id: String {
        description
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
    
    public static var local: BookmarkKey {
        .init(host: FederationKit.host, name: "", isLocal: true)
    }
    
    public static var current: BookmarkKey? {
        if let name = FederationKit.user()?.name {
            return .init(host: FederationKit.host, name: name, isLocal: false)
        } else {
            return nil
        }
    }
}

typealias CommentMap = [String:FederatedCommentResource]
