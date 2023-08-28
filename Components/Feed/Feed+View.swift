import Granite
import GraniteUI
import SwiftUI
import LemmyKit
import Nuke

extension Feed: GraniteNavigationDestination {
    var safeAreaTop: CGFloat {
#if os(iOS)
        if #available(iOS 11.0, *),
           let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.top
        }
#endif
        return 0
    }
    
    public var view: some View {
        VStack(spacing: 0) {
            switch LayoutService.style {
            case .expanded:
                horizontalLayout
            default:
                verticalLayout
            }
        }
        .background(Color.background)
        //Careful of expanded layout
        .graniteNavigationDestinationIf(isCommunity) {
            communityInfoMenuView
        }
        .task {
            guard pager.isEmpty else { return }
            
            pager.hook { page in
                
                if isLoom,
                   let manifest = state.currentLoomManifest {
                    return await manifest.fetch(page ?? 0,
                                                listing: selectedListing,
                                                sorting: selectedSort)
                } else {
                    let posts = await Lemmy.posts(state.community,
                                                  type: selectedListing,
                                                  page: page,
                                                  limit: ConfigService.Preferences.pageLimit,
                                                  sort: selectedSort,
                                                  location: state.location)
                    
                    return posts
                }
            }
            
            pager.onReset {
                Nuke.ImageCache.shared.removeAll()
            }
            
            if let community = state.community {
                fetchCommunity(community, reset: true)
            } else {
                pager.fetch()
            }
        }
    }
    
    var destinationStyle: GraniteNavigationDestinationStyle {
        .init(navBarBGColor: Color.background,
              isCustomTrailing: isCommunity)
    }
}
