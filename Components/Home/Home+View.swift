import Granite
import GraniteUI
import SwiftUI
import Foundation

extension Home: View {
    var safeAreaTop: CGFloat {
        #if os(iOS)
        return .layer1
        #else
        return 0
        #endif
    }
    
    var tabViewHeight: CGFloat {
        if Device.hasNotch {
            return 84
        } else {
            return 56
        }
    }
    
    var bottomPadding: CGFloat {
        if Device.hasNotch {
            return 20
        } else if Device.isMacOS {
            return 24
        } else if Device.isiPad {
            return 36
        } else {
            return 0
        }
    }
    
    var topPadding: CGFloat {
        if Device.isExpandedLayout {
            return 24
        } else {
            return 0
        }
    }
    
    var tabBarTopPadding: CGFloat {
        if Device.isMacOS {
            return 36
        } else if Device.isiPad {
            return 16
        } else {
            return 0
        }
    }
    
    var tabBarBottomPadding: CGFloat {
        if Device.isExpandedLayout {
            return 24
        } else {
            return 0
        }
    }
    
    @MainActor
    public var view: some View {
        GraniteTabView(.init(height: tabViewHeight,
                             paddingTabs: .init(top: tabBarTopPadding, leading: 0, bottom: tabBarBottomPadding, trailing: 0),
                             paddingIcons: .init(top: topPadding, leading: 0, bottom: bottomPadding, trailing: 0),
                             landscape: Device.isExpandedLayout,
                             enableHaptic: false) {
            
            Color.background.fitToContainer()
            
        }, currentTab: 0) {
            GraniteTab(ignoreEdges: [.top]) {
                Feed()
            } icon: {
                GraniteTabIcon(name: "house")
            }
            
            if Device.isExpandedLayout == false {
                GraniteTab {
                    Search()
                } icon: {
                    GraniteTabIcon(name: "magnifyingglass", isBoldFill: true)
                }
                
                GraniteTab {
                    Loom()
                } icon: {
                    GraniteTabIcon(name: "applescript")
                }
            }

            if Device.isExpandedLayout == false {
                GraniteTab {
                    Bookmark()
                } icon: {
                    GraniteTabIcon(name: "bookmark")
                }
            } else {
                GraniteTab {
                    Loom()
                } icon: {
                    GraniteTabIcon(name: "applescript")
                }
            }
            
//            GraniteTab {
//                Globe()
//            } icon: {
//                GraniteTabIcon(name: "globe.americas", larger: Device.isExpandedLayout == false)
//            }
            
            if Device.isExpandedLayout {
                GraniteTab(split: Device.isExpandedLayout,
                           last: true) {
                    Settings()
                } icon: {
                    GraniteTabIcon(name: "gearshape")
                }
            }
        }
        .edgesIgnoringSafeArea(edgesToEdgesToIgnore)
        .graniteNavigation(backgroundColor: Color.background) {
            Image(systemName: "chevron.backward")
                .renderingMode(.template)
                .font(.title2)
                .contentShape(Rectangle())
        }
    }
    
    var edgesToEdgesToIgnore: Edge.Set {
        if Device.isExpandedLayout {
            return [.top, .bottom]
        } else {
            return [.bottom]
        }
    }
}

struct GraniteTabIcon: View {
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var name: String
    var larger: Bool = false
    var isBoldFill: Bool = false
    
    var font: Font {
        larger ? Font.title : Font.title2
    }
    
    var body: some View {
        Image(systemName: "\(name)\(isTabSelected == true && !isBoldFill ? ".fill" : "")")
            .renderingMode(.template)
            .font(isBoldFill && isTabSelected == true ? font.bold() : font)
            .frame(width: 20,
                   height: 20,
                   alignment: .center)
            .contentShape(Rectangle())
    }
}
