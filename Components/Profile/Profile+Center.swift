import Granite
import SwiftUI
import FederationKit

extension Profile {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var person: FederatedPerson? = nil
            
            var viewingDataType: ProfilePickerView.Kind = .overview
            
            //0 all, 1 posts, 2, comments
            var overviewType: Int = 0
        }
        
        @Store public var state: State
    }
    
    var subheaderTitle: String {
        state.person?.domain?.host ?? "unknown domain"
    }
    
    var headerTitle: String {
        state.person?.name ?? "Profile"
    }
    
    var hasBanner: Bool {
        state.person?.banner != nil
    }
    
    var filterOverviewComments: Bool {
        state.viewingDataType == .overview && state.overviewType == 2
    }
    
    var filterOverviewPosts: Bool {
        state.viewingDataType == .overview && state.overviewType == 1
    }
}
