//
//  FederatedPostResource.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import NukeUI
import Combine
import MarkdownView
import FederationKit

struct PostDisplayView: GraniteNavigationDestination {
    @Environment(\.contentContext) var context
    @Environment(\.graniteNavigationShowingKey) var hasShown
    
    @GraniteAction<FederatedCommunity> var viewCommunity
    
    @Relay(.silence) var account: AccountService
    @Relay var config: ConfigService
    
    var currentModel: FederatedPostResource? {
        updatedModel ?? context.postModel
    }
    
    @State var updatedModel: FederatedPostResource?
    
    @State var showDrawer: Bool = false
    @State var commentModel: FederatedCommentResource? = nil
    
    @State var expandLinkPreview: Bool = false
    @State var enableCommunityRoute: Bool = false
    
    @State var threadLocation: FederatedLocationType = .base
    @State var listingType: FederatedListingType = .all
    
    //TODO: Similar to feed's controls maybe it can be reused?
    @State var selectedSorting: Int = 0
    var sortingType: [FederatedCommentSortType] = FederatedCommentSortType.allCases
    
    @StateObject var pager: Pager<FederatedCommentResource> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Divider()
            
            switch context.feedStyle {
            case .style1:
                contentHeader
                    .background(Color.background)
                    .id(currentModel?.post.updated)
            case .style2, .style3:
                contentHeaderStacked
                    .background(Color.background)
                    .id(currentModel?.post.updated)
            }
            
            if hasShown || Device.isExpandedLayout {
                PagerScrollView(FederatedCommentResource.self,
                                properties: .init(performant: false,
                                                  partition: Device.isMacOS == false,
                                                  lazy: true,
                                                  cacheViews: false,
                                                  showFetchMore: false)) {
                    EmptyView()
                } inlineBody: {
                    contentView
                } content: { commentView in
                    CommentCardView(context:
                            .addCommentModel(model: commentView, context)
                            .viewedIn(.postDisplay)
                            .updateLocation(threadLocation)
                            .withStyle(.style2))
                        .attach({ community in
                            viewCommunity.perform(community)
                        }, at: \.viewCommunity)
                        .graniteEvent(account.center.interact)
                        .background(Color.alternateBackground)
                }
                .environmentObject(pager)
            } else {
                Spacer()
            }
        }
        .padding(.top, Device.isExpandedLayout ? .layer4 : .layer2)
        .background(Color.background)
        .foregroundColor(.foreground)
        .task {
            self.threadLocation = context.location
            
            if updatedModel == nil {
                /*
                 - Comment cards from search won't have postViews
                 - Updating your own post from a post card will update right away
                 */
                let post = context.postModel?.post ?? context.commentModel?.post
                let postView = await Federation.post(post)
                self.updatedModel = postView
            }
            
            pager.hook { page in
                return await Federation.comments(currentModel?.post,
                                                 community: currentModel?.community,
                                                 depth: 1,
                                                 page: page,
                                                 type: listingType,
                                                 sort: sortingType[selectedSorting],
                                                 location: threadLocation)
            }.fetch()
        }
        //This overlays
        .graniteNavigationDestination(fullWidth: Device.isExpandedLayout) {
            headerView
                .padding(.leading, Device.isExpandedLayout ? 0 : .layer5)
                .padding(.top, Device.isExpandedLayout ? .layer4 : 0)
        }
    }
    
    //This inserts into a HStack
    var destinationStyle: GraniteNavigationDestinationStyle {
        return .customTrailing(Color.background,
                               fullWidth: Device.isExpandedLayout,
                               hideLeadingView: Device.isExpandedLayout)
    }
}

extension PostDisplayView {
    var headerView: some View {
        HeaderView(shouldRoutePost: false)
            .attach({ community in
                viewCommunity.perform(community)
            }, at: \.viewCommunity)
            .attach({
                ModalService.shared.showEditPostModal(currentModel) { updatedModel in
                    DispatchQueue.main.async {
                        self.updatedModel = updatedModel
                    }
                }
            }, at: \.edit)
            .contentContext(
                .addPostModel(model: updatedModel, context)
                .withStyle(context.feedStyle == .style3 ? .style2 : context.feedStyle))
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if currentModel?.hasContent == true {
                if currentModel?.post.url != nil {
                    contentLinkPreview
                        .padding(.horizontal, .layer4)
                }
                
                if currentModel?.post.body != nil {
                    contentBody
                        .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.3)
                        .padding(.top, currentModel?.post.url == nil ? .layer2 : nil)
                        .padding(.horizontal, .layer4)
                }
            }
            
            //Header refers to being a part of the focal content of the view
            //Threadview's first comment is a "header" too
            FooterView(isHeader: true,
                       showScores: config.state.showScores,
                       isComposable: true,
                       shouldLinkToPost: false)
                .attach({ model in
                    ModalService
                        .shared
                        .showReplyPostModal(model: model) { commentView in
                        pager.insert(commentView)
                    }
                }, at: \.replyPost)
                .contentContext(.addPostModel(model: updatedModel, context).withStyle(.style1))
                .padding(.horizontal, .layer4)
                .padding(.top, currentModel?.hasContent == true ? .layer5 : .layer2)
                .padding(.bottom, .layer5)
            
            Divider()
            
            sortMenuView
                .padding(.layer4)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @MainActor
    var contentHeader: some View {
        HStack(spacing: CGFloat.layer2) {
            VStack(alignment: .leading, spacing: 0) {
                Text(currentModel?.post.name ?? "")
                    .font(.title3.bold())
                    .foregroundColor(.foreground.opacity(0.9))
                    .padding(.bottom, .layer1)
            }
            
            Spacer()
            
            if let thumbUrl = currentModel?.post.thumbnail_url,
               let url = URL(string: thumbUrl) {
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.foreground.opacity(0.25))
                    
                    LazyImage(url: url) { state in
                        if let image = state.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(.foreground)
                        }
                    }
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8.0)
                .clipped()
                .onTapGesture {
                    guard let currentModel else { return }
                    GraniteHaptic.light.invoke()
                    ModalService.shared.presentSheet {
                        PostContentView(postView: currentModel)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }
            }
        }
        .padding(.horizontal, .layer4)
        .padding(.vertical, .layer3)
        .foregroundColor(.foreground)
    }
    
    @MainActor
    var contentHeaderStacked: some View {
        VStack(spacing: .layer2) {
            HStack {
                Text(currentModel?.post.name ?? "")
                    .font(.title3.bold())
                    .foregroundColor(.foreground.opacity(0.9))
                    .padding(.bottom, .layer1)
                
                Spacer()
            }
        }
        .padding(.horizontal, .layer4)
        .padding(.vertical, .layer3)
        .foregroundColor(.foreground)
    }
    var contentLinkPreview: some View {
        Group {
            if let thumbUrl = currentModel?.post.url,
               let url = URL(string: thumbUrl) {
                HStack {
                    LinkPreview(url: url)
                        .type(currentModel?.post.body == nil || expandLinkPreview ? .large : .small)
                        .frame(maxWidth: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenWidth * 0.8)
                    
                    Spacer()
                }
            }
        }
    }
    var contentBody: some View {
        VStack(spacing: 0) {
            MarkdownContainerView(text: currentModel?.post.body,
                                  kind: .postDisplay)
        }
    }
}
