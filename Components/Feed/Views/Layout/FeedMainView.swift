//
//  FeedMainView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

struct FeedMainView<Content: View>: View {
    @GraniteAction<Community> var viewCommunity
    @GraniteAction<PostView> var showContent
    @GraniteAction<(PostView?, PageableMetadata?)> var share
    
    @EnvironmentObject var pager: Pager<PostView>
    @Environment(\.graniteEvent) var interact
    
    let location: FetchType
    let header: () -> Content
    let isViewingCommunity: Bool
    let communityView: CommunityView?
    init(location: FetchType,
         communityView: CommunityView? = nil,
         @ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.location = location
        self.header = header
        self.isViewingCommunity = communityView != nil
        self.communityView = communityView
    }
    
    var body: some View {
        PagerScrollView(PostView.self,
                        properties: .init(alternateContentPosition: true,
                                          performant: true),
                        header: header) {
            EmptyView()
        } content: { postView in
            PostCardView(topPadding: pager.firstItem?.id == postView.id ? .layer5 : .layer6,
                         linkPreviewType: .largeNoMetadata)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .attach({ postView in
                    showContent.perform(postView)
                }, at: \.showContent)
                .attach({ data in
                    share.perform(data)
                }, at: \.share)
                .graniteEvent(interact)
                .contentContext(.init(postModel: postView))
        }
        .environmentObject(pager)
    }
}
