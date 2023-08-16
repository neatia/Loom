import Granite
import GraniteUI
import SwiftUI
import LemmyKit
import Nuke

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
        .onAppear {
            if content.state.lastVersionUpdateNotice != Device.appVersion {
                modal.presentSheet {
                    Group {
                        if let url = URL(string: "https://gateway.ipfs.io/ipfs/QmcsZYrrLUmi6jRqyhb4zcfijEGDUveU8HjaAgabmXfX6k") {
                            
                            PostContentView(url,
                                            fullPage: Device.isMacOS)
                                .frame(width: Device.isMacOS ? 600 : nil,
                                       height: Device.isMacOS ? 500 : nil)
                                .onAppear {
                                    
                                    content._state.lastVersionUpdateNotice.wrappedValue = Device.appVersion ?? ""
                                }
                        } else {
                            EmptyView()
                        }
                    }
                }
                
                LoomLog("\(Device.appVersion ?? "unknown app version")", level: .debug)
                
            }
        }
        .task {
            guard pager.isEmpty else { return }
            
            pager.hook { page in
                
                if loom.state.display == .expanded {
                    DispatchQueue.main.async {
                        loom._state.display.wrappedValue = .compact
                    }
                }
                
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
                //Nuke.ImageCache.shared.removeAll()
            }
            
            if let community = state.community {
                fetchCommunity(community, reset: true)
            } else {
                pager.fetch()
            }
        }
    }
}
