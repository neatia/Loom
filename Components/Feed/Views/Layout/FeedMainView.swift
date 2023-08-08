//
//  FeedMainView.swift
//  Lemur
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

struct FeedMainView<Content: View>: View {
    @GraniteAction<Community> var viewCommunity
    @EnvironmentObject var pager: Pager<PostView>
    @Environment(\.graniteEvent) var interact
    
    let location: FetchType
    let header: () -> Content
    init(location: FetchType,
         @ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.location = location
        self.header = header
    }
    
    var body: some View {
        Group {
            PagerScrollView(PostView.self,
                            alternateAddPosition: true,
                            useSimple: true,
                            cacheEnabled: true,
                            header: header) {
                EmptyView()
            } content: { postView in
                PostCardView(model: postView,
                             style: .style2,
                             topPadding: .layer5,
                             bottomPadding: pager.lastItem?.id == postView.id ? 0 : .layer5,
                             linkPreviewType: .largeNoMetadata)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
//                }, at: \.showContent)
                .graniteEvent(interact)
            }.environmentObject(pager)
        }
    }
}
