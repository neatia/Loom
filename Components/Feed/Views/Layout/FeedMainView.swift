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
    @EnvironmentObject var pager: Pager<PostView>
    @Environment(\.graniteEvent) var interact
    
    let isFrontPage: Bool
    let header: () -> Content
    init(isFrontPage: Bool,
         @ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.isFrontPage = isFrontPage
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
                             isFrontPage: isFrontPage,
                             style: .style2,
                             topPadding: .layer5,
                             bottomPadding: pager.lastItem?.id == postView.id ? 0 : .layer5,
                             linkPreviewType: .largeNoMetadata)
//                }, at: \.showContent)
                .graniteEvent(interact)
            }.environmentObject(pager)
        }
    }
}
