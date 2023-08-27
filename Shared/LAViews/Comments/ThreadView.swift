import Foundation
import SwiftUI
//import NukeUI
import Granite
import GraniteUI
import LemmyKit
import MarkdownView

struct ThreadView: View {
    @Environment(\.contentContext) var context
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.graniteEvent) var interact
    @Environment(\.graniteRouter) var router
    
    @GraniteAction<Void> var closeDrawer
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<(CommentView, ((CommentView) -> Void))> var reply
    @GraniteAction<(CommentView, ((CommentView) -> Void))> var edit
    
    @State var updatedParentModel: CommentView?
    
    //drawer
    var isModal: Bool = true
    //in PostDisplay
    var isInline: Bool = false
    
    @Relay var config: ConfigService
    
    @State var breadCrumbs: [CommentView] = []
    
    var pager: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var currentModel: CommentView? {
        breadCrumbs.last ?? (updatedParentModel ?? context.commentModel)
    }
    
    @State var threadLocation: FetchType = .base
    @State var selectedHost: String = LemmyKit.host
    var viewableHosts: [String] {
        context.viewbaleHosts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isModal {
                HeaderView(crumbs: breadCrumbs.reversed())
                    .attach({ id in
                        viewReplies(id)
                    }, at: \.tappedCrumb)
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer3)
                    .padding(.top, Device.isMacOS ? .layer4 : 0)
                
                content
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer4)
                
                Divider()
                
                sortMenuView
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.layer4)
            }
            
            PagerScrollView(CommentView.self,
                            properties: .init(hideLastDivider: true,
                                              showFetchMore: false)) { commentView in
                CommentCardView(parentModel: currentModel,
                                isInline: isInline)
                    .attach({ model in
                        if isModal {
                            breadCrumbs.append(model)
                            pager.reset()
                        } else {
                            ModalService
                                .shared
                                .showThreadDrawer(commentView: model,
                                                  context: context)
                        }
                    }, at: \.showDrawer)
                    .contentContext(.addCommentModel(model: commentView, context))
                    .graniteEvent(interact)
            }
            .environmentObject(pager)
            .background(Color.alternateBackground)
        }
        .background(isModal ? .clear : Color.background)
        .padding(.top, (Device.isMacOS || !isModal) ? 0 : .layer3)
        .task {
            self.threadLocation = context.location
            
            pager.hook { page in
                let comments = await Lemmy
                    .comments(currentModel?.post,
                              comment: currentModel?.comment,
                              community: context.community?.lemmy,
                              page: page,
                              type: .all,
                              location: threadLocation)
                
                return comments.filter { $0.id != currentModel?.id }
            }.fetch()
        }
    }
    
    func viewReplies(_ id: CommentId) {
        if let index = breadCrumbs.firstIndex(where: { $0.comment.id == id }) {
            breadCrumbs = Array(breadCrumbs.prefix(index + 1))
        } else {
            breadCrumbs.removeAll()
        }
    }
}

extension ThreadView {
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            #if os(iOS)
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.5)
                .modifier(TapAndLongPressModifier(tapAction: {
                }, longPressAction: {
                    GraniteHaptic.light.invoke()
                    closeDrawer.perform()
                }))
                .padding(.bottom, .layer5)
            #else
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.5)
                .padding(.bottom, .layer5)
            #endif
            
            FooterView(isHeader: true,
                       showScores: config.state.showScores,
                       isComposable: true)
            .attach({ model in
                router.push(style: .customTrailing(Color.background)) {
                    Reply(kind: .replyComment(model), isPushed: true)
                        .attach({ (updatedModel, replyModel) in
                            ModalService.shared.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.creator.name)", event: .success)))
                            
                            DispatchQueue.main.async {
                                self.updatedParentModel = (updatedParentModel ?? model)?.incrementReplyCount()
                                
                                self.pager.insert(model)
                                
                                self.router.pop()
                            }
                        }, at: \.updateComment)
                }
//                ModalService
//                    .shared
//                    .showReplyCommentModal(isEditing: false,
//                                           model: model) { (updatedModel, replyModel) in
//
//                    DispatchQueue.main.async {
//                        self.updatedParentModel = (updatedParentModel ?? model)?.incrementReplyCount()
//
//                        guard let replyModel else { return }
//                        pager.insert(replyModel)
//                    }
//                }
            }, at: \.replyComment)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                MarkdownView(text: currentModel?.comment.content ?? "")
                    .fontGroup(PostDisplayFontGroup())
                    .markdownViewRole(.editor)
            }
        }
    }
}

extension ThreadView {
    var sortMenuView: some View {
        HStack(spacing: .layer4) {
            Menu {
                ForEach(0..<viewableHosts.count) { index in
                    let isSource: Bool = index == 1 && currentModel?.isBaseResource == false
                    let isPeer: Bool = !isSource && index > 0
                    let imageName: String = isSource ? "globe.americas" : (isPeer ? "person.wave.2" : "house")
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        if isSource {
                            self.threadLocation = .source
                        } else if index > 0 {
                            if currentModel?.isPeerResource == true {
                                self.threadLocation = .peer(viewableHosts[index])
                            } else if context.viewingContext.isBookmark {
                                self.threadLocation = context.viewingContext.bookmarkLocation
                            }
                        } else {
                            self.threadLocation = .base
                        }
                        self.selectedHost = viewableHosts[index]
                        
                        pager.fetch(force: true)
                    } label: {
                        Text(viewableHosts[index])
                        Image(systemName: imageName)
                    }
                }
            } label: {
                Text(selectedHost)
#if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
#endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 100 : nil)
            
            Spacer()
        }
        .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
        .offset(x: (Device.isExpandedLayout) ? -2 : 0, y: 0)
    }
}
