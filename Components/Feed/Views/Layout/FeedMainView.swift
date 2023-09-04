//
//  FeedMainView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

struct FeedMainView<Content: View>: View {
    @GraniteAction<FederatedCommunity> var viewCommunity
    @GraniteAction<FederatedPostResource> var showContent
    
    @EnvironmentObject var pager: Pager<FederatedPostResource>
    @Environment(\.graniteEvent) var interact
    
    let location: FederatedLocationType
    let header: () -> Content
    let isViewingCommunity: Bool
    let communityView: FederatedCommunityResource?
    let feedStyle: FeedStyle
    init(location: FederatedLocationType,
         communityView: FederatedCommunityResource? = nil,
         feedStyle: FeedStyle = .style2,
         @ViewBuilder header: @escaping (() -> Content) = { EmptyView() }) {
        self.location = location
        self.header = header
        self.isViewingCommunity = communityView != nil
        self.communityView = communityView
        self.feedStyle = feedStyle
    }
    
    var body: some View {
        PagerScrollView(FederatedPostResource.self,
                        properties: .init(alternateContentPosition: true,
                                          performant: true,
                                          hidingHeader: true,
                                          backgroundColor: Color.background),
                        header: header) {
            EmptyView()
        } content: { postView in
            PostCardView(topPadding: pager.firstItem?.id == postView.id ? topPadding : nil,
                         linkPreviewType: .largeNoMetadata)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .graniteEvent(interact)
                .contentContext(.init(postModel: postView,
                                      preferredFeedStyle: feedStyle))
        }
        .environmentObject(pager)
    }
    
    var topPadding: CGFloat? {
        switch feedStyle {
        case .style3:
            return .layer4
        default :
            return .layer5
        }
    }
}
