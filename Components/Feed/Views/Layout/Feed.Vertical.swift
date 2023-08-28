//
//  Feed.Vertical.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

extension Feed {
    var verticalLayout: some View {
        VStack(spacing: 0) {
            FeedMainView(location: state.location,
                         communityView: state.communityView) {
                headerView
            }
             .attach({ community in
                 fetchCommunity(community, reset: true)
             }, at: \.viewCommunity)
             .graniteEvent(account.center.interact)
             .overlay(LogoView()
                .attach({
                    ModalService
                        .shared
                        .showWriteModal(state.communityView)
                }, at: \.write))
             .environmentObject(pager)
        }
        .edgesIgnoringSafeArea(state.community != nil ? [.bottom] : [])
        .sideMenuIf(state.community == nil && Device.isExpandedLayout == false,
                    isShowing: _state.isShowing) {
            accountExpandedMenuView
                .id("\(account.state.profiles.count)\(account.state.authenticated)")
        }
    }
}

