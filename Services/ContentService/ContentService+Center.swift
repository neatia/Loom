import Granite
import SwiftUI
import FederationKit

extension ContentService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var allPosts: PostMap = [:]
            var allComments: CommentMap = [:]
            var allCommunities: CommunityMap = [:]
            
            var userContent: [String:UserContent] = [:]
            
            var lastVersionUpdateNotice: String = ""
        }
        
        @Event var boot: Boot.Reducer
        @Event(debounce: 0.5) var interact: Interact.Reducer
        
        @Store(persist: "persistence.content.Loom.0027",
               autoSave: true) public var state: State
    }
}

struct Posts {
    var listingType: FederatedListingType
}

//TODO: not instance agnostic
typealias PostMap = [String:FederatedPostResource]

typealias CommunityMap = [String:FederatedCommunity]

struct UserContent: GraniteModel {
    var media: FederatedMedia
    var date: Date = .init()
    
    var isIPFS: Bool = false
    
    enum Kind: GraniteModel {
        case pictrs
    }
}

extension UserContent {
    var contentURL: String {
        //TODO: return nil
        self.media.filePath ?? ""
    }
}

