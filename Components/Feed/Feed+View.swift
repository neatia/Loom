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
            
            if let community = state.community {
                let communityView = await Lemmy.community(community: community,
                                                          useBase: state.community == nil)
                if let communityView {
                    _state.community.wrappedValue = communityView.community
                    _state.communityView.wrappedValue = communityView
                }
            }
            
            pager.hook { page in
                let posts = await Lemmy.posts(state.community,
                                              type: selectedListing,
                                              page: page,
                                              limit: ConfigService.Preferences.pageLimit,
                                              sort: selectedSort,
                                              useBase: state.community == nil)
                return posts
            }.fetch()
        }
    }
}
