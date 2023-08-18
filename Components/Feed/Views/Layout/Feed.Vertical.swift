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
            .attach({ postView in
                modal.presentSheet {
                    PostContentView(postView: postView)
                        .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                }
            }, at: \.showContent)
            .graniteEvent(account.center.interact)
            .overlay(LogoView()
                .attach({
                    modal.presentSheet {
                        Write(communityView: state.communityView)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }, at: \.write))
            .environmentObject(pager)
        }
        .edgesIgnoringSafeArea(state.community != nil ? [.bottom] : [])
    }
}
