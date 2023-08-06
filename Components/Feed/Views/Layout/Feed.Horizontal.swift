//
//  Feed.Horizontal.swift
//  Lemur
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

extension Feed {
    var minFrameWidth: CGFloat? {
        if Device.isMacOS {
            return 480
        } else if Device.isiPad {
            return 360
        } else {
            return nil
        }
    }
    
    var minFrameWidthClosed: CGFloat {
        200 + ContainerConfig.iPhoneScreenWidth + .layer1
    }
    
    //Primarily for macOS
    var horizontalLayout: some View {
        HStack(spacing: 0) {
            FeedSidebar() {
                headerView
            }
            .attach({ model in
                DispatchQueue.main.async {
                    self._state.community.wrappedValue = model.community
                    self._state.communityView.wrappedValue = model
                    self.pager.fetch(force: true)
                }
            }, at: \.pickedCommunity)
            .frame(width: 240)
            Divider()
            FeedMainView(isFrontPage: state.community != nil)
                .graniteEvent(account.center.interact)
                .environmentObject(pager)
                .frame(minWidth: minFrameWidth, maxWidth: nil)
            FeedExtendedView()
        }
    }
}
