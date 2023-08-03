import Granite
import SwiftUI
import LemmyKit

extension Write {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var title: String = ""
            var content: String = ""
            
            var imageData: Data? = nil
            var imageContent: UserContent? = nil
            var postURL: String = ""
            
            var enableMDPreview: Bool = false
            var enableImagePreview: Bool = true
            
            var selectedIPFSContentStyle: Int = 1
            var ipfsType: [String] = ["Markdown", "Classic"]
            
            var postCommunity: CommunityView? = nil
            
            var showPost: Bool = false
            var createdPostView: PostView? = nil
        }
        
        @Event var create: Write.Create.Reducer
        
        @Store public var state: State
    }
    
    var postURLColorState: Color {
        if state.postURL.isEmpty {
            return .foreground
        } else if state.postURL.isNotEmpty && state.postURL.host.isEmpty {
            return .red.opacity(0.8)
        } else {
            return .green.opacity(0.8)
        }
    }
}
