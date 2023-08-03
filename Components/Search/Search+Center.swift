import Granite
import SwiftUI
import LemmyKit

extension Search {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var postView: PostView? = nil
            var commentView: CommentView? = nil
            var showDrawer: Bool = false
            
            var selectedSearchType: Int = 0
            var searchType: [SearchType] = SearchType.allCases
            
            var selectedTimeCategory: Int = 0
            var sortingTimeType: [String] = ["All Time", "Today"]
            
            var selectedSorting: Int = 0
            var sortingType: [SortType] = SortType.categoryGeneral
            
            var selectedListing: Int = 0
            var listingType: [ListingType] = ListingType.allCases
        }
        
        @Store public var state: State
    }
    
    var selectedSearch: SearchType {
        state.searchType[state.selectedSearchType]
    }
    
    var selectedSort: SortType {
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
    
    var selectedListing: ListingType {
        state.listingType[state.selectedListing]
    }
}

extension SearchType {
    var displayString: String {
        "\(self.rawValue)"
    }
}
