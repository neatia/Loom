//
//  Feed.Vertical.swift
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
    var verticalLayout: some View {
        VStack(spacing: 0) {
            FeedMainView(location: state.location) {
                headerView
            }
            .attach({ community in
                fetchCommunity(community, reset: true)
            }, at: \.viewCommunity)
            .graniteEvent(account.center.interact)
            .environmentObject(pager)
        }
    }
}
