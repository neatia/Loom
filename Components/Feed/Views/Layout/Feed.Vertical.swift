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
            FeedMainView(isFrontPage: state.community == nil) {
                headerView
            }
            .graniteEvent(account.center.interact)
            .environmentObject(pager)
        }
    }
}
