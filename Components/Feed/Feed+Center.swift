import Granite
import SwiftUI
import LemmyKit

extension Feed {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var community: Community? = nil
            var communityView: CommunityView? = nil
            
            var isDropdownSortActive: Bool = false
            var isDropdownListingActive: Bool = false
            
            var isDropdownActive: Bool {
                isDropdownSortActive || isDropdownListingActive
            }
            
            var selectedTimeCategory: Int = 0
            var sortingTimeType: [String] = ["SORT_TYPE_ALL_TIME", "SORT_TYPE_TODAY"]
            
            var selectedSorting: Int = 0
            var sortingType: [SortType] = SortType.categoryGeneral
            
            var selectedListing: Int = 0
            var listingType: [ListingType] = ListingType.allCases
            
            var sortingOrListingChanged: Int {
                selectedListing + selectedSorting + selectedTimeCategory
            }
        }
        
        @Store public var state: State
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
    
    var headerTitle: LocalizedStringKey {
        if let community = state.community {
            return .init(community.title)
        } else {
            return "TITLE_FRONT_PAGE"
        }
    }
    
    var subheaderTitle: String {
        if let community = state.community {
            if community.actor_id.host != LemmyKit.host {
                return community.name+"@"+community.actor_id.host
            } else {
                return community.actor_id.host
            }
        } else {
            return LemmyKit.host
        }
    }
    
    var isCommunity: Bool {
        state.community != nil
    }
    var hasCommunityBanner: Bool {
        isCommunity && state.community?.banner != nil
    }
    
    func fetchCommunity(_ model: Community? = nil, reset: Bool = false) {
        let community: Community? = model ?? state.community
        
        guard let community else { return }
        _ = Task.detached {
            let communityView = await Lemmy.community(community: community)
            
            DispatchQueue.main.async {
                self._state.community.wrappedValue = model
                self._state.communityView.wrappedValue = communityView
            }
            
            if reset {
                await self.pager.fetch(force: true)
            }
        }
    }
}

extension SortType {
    static var categoryGeneral: [SortType] {
        [.hot, .active, .topAll, .new,]
    }
    
    static var categoryTime: [SortType] {
        [.topAll, .topYear, .topDay]
    }
    
    var isTime: Bool {
        switch self {
        case .topAll, .topMonth, .topDay, .topYear, .topHour, .topWeek:
            return true
        default:
            return false
        }
    }
    
    var displayString: LocalizedStringKey {
        switch self {
        case .topAll:
            return "SORT_TYPE_TOP"
        case .topYear:
            return "SORT_TYPE_YEAR"
        case .topDay:
            return "SORT_TYPE_TODAY"
        case .hot:
            return "SORT_TYPE_HOT"
        case .active:
            return "SORT_TYPE_ACTIVE"
        case .new:
            return "SORT_TYPE_NEW"
        case .old:
            return "SORT_TYPE_OLD"
        default:
            return .init(self.rawValue)
        }
    }
}

extension ListingType {
    var abbreviated: String {
        switch self {
        case .subscribed:
            return "sub."
        default:
            return self.rawValue
        }
    }
    
    var displayString: LocalizedStringKey {
        switch self {
        case .all:
            return "LISTING_TYPE_ALL"
        case .local:
            return "LISTING_TYPE_LOCAL"
        case .subscribed:
            return "LISTING_TYPE_SUBSCRIBED"
        }
    }
}
