import Granite
import SwiftUI
import FederationKit

extension Search {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var postView: FederatedPostResource? = nil
            var commentView: FederatedCommentResource? = nil
            var showDrawer: Bool = false
            
            var selectedSearchType: Int = 0
            var searchType: [FederatedSearchType] = FederatedSearchType.allCases
            
            var selectedTimeCategory: Int = 0
            var sortingTimeType: [String] = ["All Time", "Today"]
            
            var selectedSorting: Int = 0
            var sortingType: [FederatedSortType] = FederatedSortType.categoryGeneral
            
            var selectedListing: Int = 0
            var listingType: [FederatedListingType] = FederatedListingType.allCases
        }
        
        @Store public var state: State
    }
    
    var selectedSearch: FederatedSearchType {
        state.searchType[state.selectedSearchType]
    }
    
    var selectedSort: FederatedSortType {
        switch state.sortingType[state.selectedSorting] {
        case .topAll:
            switch state.sortingTimeType[state.selectedTimeCategory].lowercased() {
            case "all time":
                return .topAll
            case "today":
                return .topDay
            default:
                return .topAll
            }
        default:
            return state.sortingType[state.selectedSorting]
        }
    }
    
    var selectedListing: FederatedListingType {
        state.listingType[state.selectedListing]
    }
}

extension FederatedSearchType {
    var displayString: String {
        "\(self.rawValue)"
    }
}
