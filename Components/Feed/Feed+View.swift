import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Feed: View {
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
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
        .addGraniteModal(modal.modalManager)
        .graniteNavigationDestinationIf(state.community != nil, trailingItems: {
            communityInfoView
        })
        .background(Color.background)
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
            
            if let community = state.community {
                fetchCommunity(community, reset: true)
            } else {
                pager.fetch()
            }
        }
    }
}
