//
//  PostView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import LemmyKit
import NukeUI
import Combine
import MarkdownView

struct PostDisplayView: GraniteNavigationDestination {
    @Environment(\.contentContext) var context
    @Environment(\.graniteNavigationShowingKey) var hasShown
    
    @GraniteAction<Community> var viewCommunity
    
    @Relay(.silence) var account: AccountService
    @Relay var config: ConfigService
    
    var model: PostView? {
        updatedModel ?? context.postModel
    }
    
    @State var updatedModel: PostView?
    
    @State var showDrawer: Bool = false
    @State var commentModel: CommentView? = nil
    
    @State var expandLinkPreview: Bool = false
    @State var enableCommunityRoute: Bool = false
    
    @State var threadLocation: FetchType = .base
    
    //TODO: Similar to feed's controls maybe it can be reused?
    @State var selectedSorting: Int = 0
    var sortingType: [CommentSortType] = CommentSortType.allCases
    @State var selectedHost: String = LemmyKit.host
    
    var isPushed: Bool = false
    
    var viewableHosts: [String] {
        context.viewbaleHosts
    }
    
    @StateObject var pager: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if Device.isExpandedLayout {
                headerView
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer3)
            }

            Divider()
                
            
            switch context.feedStyle {
            case .style1:
                contentHeader
                    .background(Color.background)
            case .style2:
                contentHeaderStacked
                    .background(Color.background)
            }
            
            if hasShown || Device.isExpandedLayout {
                PagerScrollView(CommentView.self,
                                properties: .init(performant: false,
                                                  partition: Device.isMacOS == false,
                                                  lazy: true,
                                                  cacheViews: false,
                                                  showFetchMore: false)) {
                    EmptyView()
                } inlineBody: {
                    contentView
                } content: { commentView in
                    CommentCardView()
                        .attach({ community in
                            viewCommunity.perform(community)
                        }, at: \.viewCommunity)
                        .contentContext(
                            .addCommentModel(model: commentView, context)
                            .viewedIn(.postDisplay)
                            .updateLocation(threadLocation))
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
                let postId = context.postModel?.post.id ?? context.commentModel?.post.id
                let postView = await Lemmy.post(postId)
                self.updatedModel = postView
            }
            
            pager.hook { page in
                return await Lemmy.comments(model?.post,
                                            community: model?.community,
                                            page: page,
                                            type: .all,
                                            sort: sortingType[selectedSorting],
                                            location: threadLocation)
            }.fetch()
        }
        .ignoresSafeArea(.keyboard)
        //This overlays
        .graniteNavigationDestinationIf(isPushed) {
            headerView
                .padding(.leading, .layer5)
        }
    }
    
    //This inserts into a HStack
    var destinationStyle: GraniteNavigationDestinationStyle {
        if Device.isExpandedLayout {
            return .init(navBarBGColor: Color.background)
        } else {
            return .init(fullWidth: true, navBarBGColor: Color.background) {
                headerView
                    .padding(.leading, .layer4)
            }
        }
    }
}

extension PostDisplayView {
    var headerView: some View {
        HeaderView(shouldRoutePost: false)
            .attach({ community in
                viewCommunity.perform(community)
            }, at: \.viewCommunity)
            .attach({
                ModalService.shared.showEditPostModal(model) { updatedModel in
                    DispatchQueue.main.async {
                        self.updatedModel = updatedModel
                        ModalService.shared.dismissSheet()
                    }
                }
            }, at: \.edit)
            .contentContext(.addPostModel(model: updatedModel, context))
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if model?.hasContent == true {
                if model?.post.url != nil {
                    contentLinkPreview
                        .padding(.horizontal, .layer4)
                }
                
                if model?.post.body != nil {
                    contentBody
                        .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.3)
                        .padding(.top, model?.post.url == nil ? .layer2 : nil)
                        .padding(.horizontal, .layer4)
                }
            }
            
            //Header refers to being a part of the focal content of the view
            //Threadview's first comment is a "header" too
            FooterView(isHeader: true,
                       showScores: config.state.showScores,
                       isComposable: true)
                .attach({ model in
                    ModalService
                        .shared
                        .showReplyPostModal(model: model) { commentView in
                        pager.insert(commentView)
                    }
                }, at: \.replyPost)
                .contentContext(.addPostModel(model: updatedModel, context).withStyle(.style1))
                .padding(.horizontal, .layer4)
                .padding(.top, model?.hasContent == true ? .layer5 : .layer2)
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
                Text(model?.post.name ?? "")
                    .font(.title3.bold())
                    .foregroundColor(.foreground.opacity(0.9))
                    .padding(.bottom, .layer1)
            }
            
            Spacer()
            
            if let thumbUrl = model?.post.thumbnail_url,
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
                    guard let model else { return }
                    GraniteHaptic.light.invoke()
                    ModalService.shared.presentSheet {
                        PostContentView(postView: model)
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
                Text(model?.post.name ?? "")
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
            if let thumbUrl = model?.post.url,
               let url = URL(string: thumbUrl) {
                HStack {
                    LinkPreview(url: url)
                        .type(model?.post.body == nil || expandLinkPreview ? .large : .small)
                        .frame(maxWidth: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenWidth * 0.8)
                    
                    Spacer()
                }
            }
        }
    }
    var contentBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let body = model?.post.body {
                    MarkdownView(text: body)
                        .markdownViewRole(.editor)
                        .fontGroup(PostDisplayFontGroup())
                        .padding(.bottom, .layer2)
                }
            }
        }
    }
}
