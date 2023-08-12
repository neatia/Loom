import Granite
import SwiftUI
import LemmyKit

extension Bookmark {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var kind: Kind = .posts
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
    
    var postViews: [PostView] {
        
        Array(service.state.posts.values.flatMap { obj in
            
            Array(
                obj.map.values
            )
            
        }).sorted(by: { service.state.datesPosts[($0.creator.domain ?? "")+$0.id]?.compare(service.state.datesPosts[($1.creator.domain ?? "")+$1.id] ?? .init()) == .orderedDescending })
    }
    
    var commentViews: [CommentView] {
        Array(service.state.comments.values.flatMap { obj in
            
            Array(
                obj.map.values
            )
            
        }).sorted(by: { service.state.datesComments[($0.creator.domain ?? "")+$0.id]?.compare(service.state.datesComments[($1.creator.domain ?? "")+$1.id] ?? .init()) == .orderedDescending })
    }
    
    func postForComment(_ commentView: CommentView) -> PostView? {
        guard let domain = commentView.creator.domain else {
            return nil
        }
        return service.state.comments[domain]?.postMap[commentView.post.id]
    }
}
