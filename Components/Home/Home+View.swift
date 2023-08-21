import Granite
import GraniteUI

import SwiftUI
import Foundation

extension Home: View {
    var safeAreaTop: CGFloat {
        #if os(iOS)
        return .layer1
        #endif
        return 0
    }
    
    var isBottom: Bool {
        #if os(iOS)
        if #available(iOS 11.0, *),
           let keyWindow = UIApplication.shared.keyWindow,
           keyWindow.safeAreaInsets.bottom > 0 {
            return true
        }
        #endif
        return false
    }
    
    var tabViewHeight: CGFloat {
        if Device.isExpandedLayout {
            return 56
        } else {
            return 84
        }
    }
    
    var bottomPadding: CGFloat {
        if isBottom && Device.isExpandedLayout == false {
            return 20
        } else if Device.isMacOS {
            return 24
        } else if Device.isiPad {
            return 36
        } else {
            return 10
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
                             landscape: Device.isExpandedLayout) {
            
            Color.background.fitToContainer()
            
        }, currentTab: 0) {
            GraniteTab {
                Feed()
            } icon: {
                GraniteTabIcon(name: "house")
            }
            
            GraniteTab {
                Globe()
            } icon: {
                GraniteTabIcon(name: "globe.americas", larger: true)
            }

            GraniteTab {
                Loom()
            } icon: {
                GraniteTabIcon(name: "applescript")
            }

            if Device.isExpandedLayout == false {
                GraniteTab {
                    Bookmark()
                } icon: {
                    GraniteTabIcon(name: "bookmark")
                }
            }
            
            if Device.isExpandedLayout {
                GraniteTab(split: Device.isExpandedLayout,
                           last: true) {
                    Settings()
                } icon: {
                    GraniteTabIcon(name: "gearshape")
                }
            }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .padding(.top, safeAreaTop)
        .graniteNavigation(backgroundColor: Color.background, disable: Device.isExpandedLayout) {
            Image(systemName: "chevron.backward")
                .renderingMode(.template)
                .font(.title3)
                .contentShape(Rectangle())
                .offset(x: -.layer1)
        }
    }
}

struct GraniteTabIcon: View {
    @Environment(\.graniteTabSelected) var isTabSelected
    
    var name: String
    var larger: Bool = false
    
    var body: some View {
        Image(systemName: "\(name)\(isTabSelected == true ? ".fill" : "")")
            .renderingMode(.template)
            .font(larger ? Font.title : Font.title2)
            .frame(width: 20,
                   height: 20,
                   alignment: .center)
            .padding(.top, larger ? 2 : 0)
            .contentShape(Rectangle())
    }
}
