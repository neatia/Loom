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
            PagerScrollView(PostView.self,
                            alternateAddPosition: true,
                            useList: false) {//Device.isMacOS) {
                headerView
            } inlineBody: {
                EmptyView()
            } content: { postView in
                PostCardView(model: postView,
                             isFrontPage: state.community == nil,
                             style: .style2,
                             linkPreviewType: config.state.linkPreviewMetaData ? .large : .largeNoMetadata)
                .attach({
                    GraniteHaptic.light.invoke()
                    modal.presentSheet {
                        PostContentView(postView: postView)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }, at: \.showContent)
                .graniteEvent(account.center.interact)
            }.environmentObject(pager)
        }
    }
}
