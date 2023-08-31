import Granite
import SwiftUI
import FederationKit

extension Bookmark {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var kind: Kind = .posts
            var selectedBookmarkPostKey: BookmarkKey = .local
            var selectedBookmarkCommentKey: BookmarkKey = .local
        }
        
        @Store public var state: State
    }
    
    enum Kind: String, Equatable, Codable {
        case posts
        case comments
    }
    
    var postsHeaderOpacity: CGFloat {
        return state.kind == .posts ? 1.0 : 0.6
    }
    
    var commentsHeaderOpacity: CGFloat {
        return state.kind == .comments ? 1.0 : 0.6
    }
    
    var postsFont: Font {
        if showHeader {
            return state.kind == .posts ? .title2.bold() : .title3.bold()
        } else {
            return state.kind == .posts ? .title3.bold() : .headline.bold()
        }
    }
    
    var commentsFont: Font {
        if showHeader {
            return state.kind == .comments ? .title2.bold() : .title3.bold()
        } else {
            return state.kind == .comments ? .title3.bold() : .headline.bold()
        }
    }
    
    var postViews: [FederatedPostResource] {
        guard let values = service.state.posts[state.selectedBookmarkPostKey]?.values else {
            return []
        }
        return Array(values.flatMap { obj in
            
            Array(
                obj.map.values
            )
            
        }).sorted(by: { service.state.datesPosts[($0.creator.domain ?? "")+$0.id]?.compare(service.state.datesPosts[($1.creator.domain ?? "")+$1.id] ?? .init()) == .orderedDescending })
    }
    
    var commentViews: [FederatedCommentResource] {
        guard let values = service.state.comments[state.selectedBookmarkCommentKey]?.values else {
            return []
        }
        
        return Array(values.flatMap { obj in
            
            Array(
                obj.map.values
            )
            
        }).sorted(by: { service.state.datesComments[($0.creator.domain ?? "")+$0.id]?.compare(service.state.datesComments[($1.creator.domain ?? "")+$1.id] ?? .init()) == .orderedDescending })
    }
    
    func postForComment(_ commentView: FederatedCommentResource) -> FederatedPostResource? {
        guard let domain = commentView.creator.domain else {
            return nil
        }
        return service.state.comments[state.selectedBookmarkCommentKey]?[domain]?.postMap[commentView.post.id]
    }
}

extension Bookmark {
    var bookmarkKeys: [BookmarkKey] {
        switch state.kind {
        case .posts:
            return Array(service.state.posts.keys)
        case .comments:
            return Array(service.state.comments.keys)
        }
    }
}
