import Granite
import SwiftUI
import FederationKit

extension Feed {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var community: FederatedCommunity? = nil
            var communityView: FederatedCommunityResource? = nil
            
            var selectedTimeCategory: Int = 0
            //Listing type localizatin used for abbreviation: "All Time"
            var sortingTimeType: [String] = ["LISTING_TYPE_ALL", "SORT_TYPE_TODAY"]
            
            var selectedSorting: Int = 0
            var sortingType: [FederatedSortType] = FederatedSortType.categoryGeneral
            
            var selectedListing: Int = 0
            var listingType: [FederatedListingType] = FederatedListingType.allCases
            
            var socialViewOptions: Int = 0
            
            var sortingOrListingChanged: Int {
                selectedListing + selectedSorting + selectedTimeCategory
            }
            
            var location: FederatedLocationType = .base
            var peerLocation: FederatedLocationType? = nil
            
            var isShowing: Bool = false
            
            //Loom
            var currentLoomManifest: LoomManifest? = nil
        }
        
        @Event var goHome: GoHome.Reducer
        
        @Store public var state: State
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
    
    var headerTitle: LocalizedStringKey {
        if isLoom, let manifest = state.currentLoomManifest {
            return .init(manifest.meta.name)
        } else if let community = state.community {
            return .init(community.title)
        } else {
            return "TITLE_FRONT_PAGE"
        }
    }
    
    var subheaderTitle: String {
        if isLoom {
            //TODO: localize
            return "Loom"
        } else if let community = state.community {
            switch state.location {
            case .peer(let host):
                return host+"@"+community.actor_id.host
            case .source:
                return community.actor_id.host
            case .base:
                if FederationKit.host == state.community?.actor_id.host {
                    return FederationKit.host
                } else {
                    return FederationKit.host+"@"+community.actor_id.host
                }
            }
        } else {
            return FederationKit.host
        }
    }
    
    var isLoom: Bool {
        state.currentLoomManifest != nil
    }
    
    var hasCommunityBanner: Bool {
        isCommunity && state.community?.banner != nil
    }
    
    func fetchCommunity(_ model: FederatedCommunity? = nil,
                        location: FederatedLocationType? = nil,
                        reset: Bool = false) {
        let feedLocation = location ?? state.location
        let community: FederatedCommunity? = model ?? state.community
        
        guard let community else { return }
        
        _ = Task.detached {
            let communityResource = await Federation.community(community: community,
                                                               location: feedLocation)
            
            DispatchQueue.main.async {
                self._state.community.wrappedValue = model
                self._state.communityView.wrappedValue = communityResource
                if let location {
                    self._state.location.wrappedValue = location
                }
                
                if reset {
                    self.pager.reset()
                }
            }
        }
    }
}
