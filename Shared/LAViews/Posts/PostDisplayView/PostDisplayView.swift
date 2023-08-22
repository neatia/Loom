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
    @GraniteAction<Community> var viewCommunity
    
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
    
    var viewableHosts: [String] {
        var hosts: [String] = [LemmyKit.host]
        
        guard let model else { return [] }
        
        if model.isBaseResource == false {
            hosts += [model.community.actor_id.host]
        }
        
        if model.isPeerResource {
            hosts += [model.creator.actor_id.host]
        }
        
        if context.viewingContext.isBookmark,
           case .peer(let host) = context.viewingContext.bookmarkLocation {
            hosts += [host]
        }
        
        return hosts
    }
    
    @StateObject var pager: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if Device.isExpandedLayout {
                headerView
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer4)
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

            PagerScrollView(CommentView.self,
                            properties: .init(performant: Device.isMacOS == false,
                                              cacheViews: true,
                                              showFetchMore: false)) {
                EmptyView()
            } inlineBody: {
                contentView
            } content: { commentView in
                CommentCardView()
                    .attach({ model in
                        self.showDrawer = true
                        self.commentModel = model
                    }, at: \.showDrawer)
                    .attach({ community in
                        viewCommunity.perform(community)
                    }, at: \.viewCommunity)
                    .contentContext(.addCommentModel(model: commentView, context))
                    .background(Color.alternateBackground)
            }
            .environmentObject(pager)
        }
        .padding(.top, Device.isExpandedLayout ? .layer4 : .layer2)
        //.addGraniteSheet(modal.sheetManager, background: Color.clear)
        .background(Color.background)
        .foregroundColor(.foreground)
        .showDrawer($showDrawer,
                    commentView: commentModel,
                    context: context)
        .task {
            self.threadLocation = context.location
            
            guard let model else { return }
            
            pager.hook { page in
                return await Lemmy.comments(model.post,
                                            community: model.community,
                                            page: page,
                                            type: .all,
                                            sort: sortingType[selectedSorting],
                                            location: threadLocation)
            }.fetch()
        }
    }
    
    var destinationStyle: GraniteNavigationDestinationStyle {
        if Device.isExpandedLayout {
            return .init()
        } else {
            return .init(fullWidth: true) {
                headerView
                    .padding(.horizontal, .layer3)
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
            .contentContext(context)
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
            
            FooterView(isHeader: true,
                       showScores: config.state.showScores,
                       isComposable: true)
                .attach({ model in
                    ModalService
                        .shared
                        .showReplyPostModal(model: model) { postView in
                        pager.insert(postView)
                    }
                }, at: \.reply)
                .contentContext(.withStyle(.style1, context))
                .padding(.horizontal, .layer4)
                .padding(.vertical, .layer5)
            
            Divider()
            
            sortMenuView
                .padding(.layer4)
                .addHaptic()
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


fileprivate extension View {
    func showDrawer(_ condition: Binding<Bool>,
                    commentView: CommentView?,
                    context: ContentContext) -> some View {
        self.overlayIf(condition.wrappedValue, alignment: .top) {
            Group {
                if let commentView {
                    #if os(iOS)
                    Drawer(startingHeight: 480) {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color.background)
                                .shadow(radius: 100)
                            
                            VStack(alignment: .center, spacing: 0) {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 50, height: 8)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, .layer5)
                                ThreadView()
                                    .attach({
                                        condition.wrappedValue = false
                                    }, at: \.closeDrawer)
                                    .contentContext(.addCommentModel(model: commentView, context))
                                Spacer()
                            }
                            .frame(height: UIScreen.main.bounds.height - 100)
                        }
                    }
                    .rest(at: .constant([100, 480, UIScreen.main.bounds.height - 100]))
                    .impact(.light)
                    .edgesIgnoringSafeArea(.vertical)
                    .transition(.move(edge: .bottom))
                    .id(commentView.comment.id)
                    #endif
                }
            }
        }
    }
}
