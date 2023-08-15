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
        ZStack {
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
                .attach({ postView in
                    showContent.perform(postView)
                }, at: \.showContent)
                .graniteEvent(interact)
            }
            .environmentObject(pager)
            
            Loom(communityView: communityView)
                .padding(.bottom,
                         isViewingCommunity ? .layer4 : 0)
        }
        .adaptsToKeyboard()
    }
}
