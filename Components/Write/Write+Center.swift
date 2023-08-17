import Granite
import SwiftUI
import LemmyKit

extension Write {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var isEditing: Bool {
                editingPostView != nil
            }
            var editingPostView: PostView? = nil
            
            var title: String = ""
            var content: String = ""
            
            var imageData: Data? = nil
            var imageContent: UserContent? = nil
            var postURL: String = ""
            
            var enableMDPreview: Bool = false
            var enableImagePreview: Bool = true
            
            var postCommunity: CommunityView? = nil
            
            var showPost: Bool = false
            var createdPostView: PostView? = nil
            
            var isPosting: Bool = false
        }
        
        @Event(debounce: 0.25) var create: Write.Create.Reducer
        
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
    
    var imageColorState: Color {
        if state.imageData == nil {
            return .foreground
        } else if state.imageContent == nil && state.imageData != nil {
            return .red.opacity(0.8)
        } else {
            return .green.opacity(0.8)
        }
    }
}
