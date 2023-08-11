import Granite
import SwiftUI
import LemmyKit

extension ContentService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var allPosts: PostMap = [:]
            var allComments: CommentMap = [:]
            var allCommunities: CommunityMap = [:]
            
            var userContent: [String:UserContent] = [:]
        }
        
        @Event var boot: Boot.Reducer
        @Event(debounce: 0.5) var interact: Interact.Reducer
        
        @Store(persist: "persistence.content.Loom.0018", autoSave: true) public var state: State
    }
}

struct Posts {
    var listingType: ListingType
}

//TODO: not instance agnostic
typealias PostMap = [String:PostView]

typealias CommunityMap = [String:Community]

struct UserContent: GraniteModel {
    var imageFile: ImageFile
    var date: Date = .init()
    
    var isIPFS: Bool = false
    
    enum Kind: GraniteModel {
        case pictrs
    }
}

extension UserContent {
    var contentURL: String {
        if isIPFS {
            return self.imageFile.file
        } else {
            return LemmyKit.current.contentURL + "/" + self.imageFile.file
        }
    }
}

