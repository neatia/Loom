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

struct PostDisplayView: View {
    @GraniteAction<Community> var viewCommunity
    
    @Relay var config: ConfigService
    @Relay var modal: ModalService
    
    @State var model: PostView
    var style: FeedStyle = .style2
    
    @State var showDrawer: Bool = false
    @State var commentModel: CommentView? = nil
    @State var expandLinkPreview: Bool = false
    
    @State var enableCommunityRoute: Bool = false
    
    @State var threadLocation: FetchType = .base
    
    var viewingContext: ViewingContext = .base
    
    //TODO: Similar to feed's controls maybe it can be reused?
    @State var selectedSorting: Int = 0
    var sortingType: [CommentSortType] = CommentSortType.allCases
    @State var selectedHost: String = LemmyKit.host
    
    var viewableHosts: [String] {
        var hosts: [String] = [LemmyKit.host]
        
        if model.isBaseResource == false {
            hosts += [model.community.actor_id.host]
        }
        
        if model.isPeerResource {
            hosts += [model.creator.actor_id.host]
        }
        
        if viewingContext.isBookmark,
           case .peer(let host) = viewingContext.bookmarkLocation {
            hosts += [host]
        }
        
        return hosts
    }
    
    @StateObject var comments: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView(model, shouldRoutePost: false, badge: .noBadge)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                .attach({
                    modal.presentSheet {
                        Write(postView: model)
                            .attach({ updatedModel in
                                DispatchQueue.main.async {
                                    self.model = updatedModel
                                    self.modal.dismissSheet()
                                }
                            }, at: \.updatedPost)
                            .frame(width: Device.isMacOS ? 700 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }, at: \.edit)
                .padding(.horizontal, .layer3)
                .padding(.bottom, .layer4)

            Divider()
            
            switch style {
            case .style1:
                contentHeader
                    .background(Color.background)
            case .style2:
                contentHeaderStacked
                    .background(Color.background)
            }

            PagerScrollView(CommentView.self) {
                EmptyView()
            } inlineBody: {
                content
            } content: { comment in
                CommentCardView(model: comment,
                                postView: model)
                    .attach({ model in
                        self.showDrawer = true
                        self.commentModel = model
                    }, at: \.showDrawer)
                    .attach({ community in
                        viewCommunity.perform(community)
                    }, at: \.viewCommunity)
                    .attach({ (model, update) in
                        modal.presentSheet {
                            Reply(kind: .replyComment(model))
                                .attach({ replyModel in
                                    update(replyModel)
                                    
                                    modal.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.creator.name)", event: .success)))
                                    
                                    modal.dismissSheet()
                                }, at: \.updateComment)
                                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    }, at: \.reply)
            }
            .environmentObject(comments)
        }
        .padding(.top, .layer4)
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
        .background(Color.background)
        .foregroundColor(.foreground)
        .showDrawer($showDrawer,
                    commentView: commentModel,
                    postView: model)
        .task {
            if viewingContext.isBookmark == false {
                threadLocation = model.post.location ?? .base
            }
            comments.hook { page in
                return await Lemmy.comments(model.post,
                                            community: model.community,
                                            page: page,
                                            type: .all,
                                            sort: sortingType[selectedSorting],
                                            location: threadLocation)
            }.fetch()
        }
    }
}

extension PostDisplayView {
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            if model.hasContent {
                if model.post.url != nil {
                    contentLinkPreview
                        .padding(.horizontal, .layer4)
                }
                
                if model.post.body != nil {
                    contentBody
                        .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.3)
                        .padding(.top, model.post.url == nil ? .layer2 : nil)
                        .padding(.horizontal, .layer4)
                }
            }
            
            FooterView(postView: model,
                       commentView: nil,
                       isHeader: true,
                       showScores: config.state.showScores,
                       isComposable: true)
                .attach({ model in
                    modal.presentSheet {
                        Reply(kind: .replyPost(model))
                            .attach({ (model, modelView) in
                                comments.insert(modelView)
                                
                                modal.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_COMMENT_SUCCESS", event: .success)))
                                
                                modal.dismissSheet()
                            }, at: \.updatePost)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }, at: \.reply)
                .padding(.horizontal, .layer4)
                .padding(.vertical, .layer4)
            
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
                Text(model.post.name)
                    .font(.title3.bold())
                    .foregroundColor(.foreground.opacity(0.9))
                    .padding(.bottom, .layer1)
            }
            
            Spacer()
            
            if let thumbUrl = model.post.thumbnail_url,
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
                    GraniteHaptic.light.invoke()
                    modal.presentSheet {
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
                Text(model.post.name)
                    .font(.title3)
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
            if let thumbUrl = model.post.url,
               let url = URL(string: thumbUrl) {
                HStack {
                    LinkPreview(url: url)
                        .type(model.post.body == nil || expandLinkPreview ? .large : .small)
                        .frame(maxWidth: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenWidth * 0.8)
                    
                    Spacer()
                }
            }
        }
    }
    var contentBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let body = model.post.body {
                    MarkdownView(text: body)
                        .markdownViewRole(.editor)
                        .padding(.bottom, .layer2)
                }
            }
        }
    }
}


fileprivate extension View {
    func showDrawer(_ condition: Binding<Bool>,
                    commentView: CommentView?,
                    postView: PostView?) -> some View {
        self.overlayIf(condition.wrappedValue, alignment: .top) {
            Group {
                #if os(iOS)
                if let commentView {
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
                                ThreadView(model: commentView, postView: postView)
                                    .attach({
                                        condition.wrappedValue = false
                                    }, at: \.closeDrawer)
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
                }
                #endif
            }
        }
    }
}
