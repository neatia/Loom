import Foundation
import SwiftUI
//import NukeUI
import Granite
import GraniteUI
import MarkdownView
import FederationKit

struct ThreadView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.graniteEvent) var interact
    @Environment(\.graniteRouter) var router
    
    var context: ContentContext
    
    @GraniteAction<Void> var closeDrawer
    @GraniteAction<FederatedCommentResource> var showDrawer
    @GraniteAction<(FederatedCommentResource, ((FederatedCommentResource) -> Void))> var reply
    @GraniteAction<(FederatedCommentResource, ((FederatedCommentResource) -> Void))> var edit
    
    @State var updatedParentModel: FederatedCommentResource?
    
    //drawer
    var isModal: Bool = true
    //in PostDisplay
    var isInline: Bool = false
    
    @Relay var config: ConfigService
    
    @State var breadCrumbs: [FederatedCommentResource] = []
    
    @StateObject var pager: Pager<FederatedCommentResource> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var currentModel: FederatedCommentResource? {
        breadCrumbs.last ?? (updatedParentModel ?? context.commentModel)
    }
    
    @State var threadLocation: FederatedLocationType = .base
    @State var listingType: FederatedListingType = .all
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isModal {
                HeaderView(crumbs: breadCrumbs.reversed())
                    .attach({ id in
                        viewReplies(id)
                    }, at: \.tappedCrumb)
                    .contentContext(context)
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer3)
                    .padding(.top, Device.isMacOS ? .layer4 : 0)
                
                contentView
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer4)
                
                Divider()
                
                ListingSelectorView(listingType: $listingType)
                    .attach({
                        pager.reset()
                    }, at: \.fetch)
                    //nitpick
                    .offset(x: (Device.isExpandedLayout) ? -2 : 0, y: 0)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.layer4)
            }
            
            PagerScrollView(FederatedCommentResource.self,
                            properties: .init(hideLastDivider: true,
                                              performant: Device.isMacOS == false,
                                              showFetchMore: false)) { commentView in
                CommentCardView(context: .addCommentModel(model: commentView,
                                                          context).withStyle(.style2),
                                parentModel: currentModel,
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
                let comments = await Federation.comments(currentModel?.post,
                                                         comment: currentModel?.comment,
                                                         community: context.community,
                                                         depth: 1,
                                                         page: page,
                                                         type: listingType,
                                                         location: threadLocation)
                
                return comments.filter { $0.id != currentModel?.id }
            }.fetch()
        }
    }
    
    func viewReplies(_ id: String) {
        if let index = breadCrumbs.firstIndex(where: { $0.comment.id == id }) {
            breadCrumbs = Array(breadCrumbs.prefix(index + 1))
        } else {
            print("breadCrumbs removed all")
            breadCrumbs.removeAll()
        }
        
        pager.reset()
    }
}

extension ThreadView {
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            #if os(iOS)
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.35)
                .modifier(TapAndLongPressModifier(tapAction: {
                }, longPressAction: {
                    GraniteHaptic.light.invoke()
                    closeDrawer.perform()
                }))
                .padding(.bottom, .layer5)
            #else
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.35)
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
            }, at: \.replyComment)
            .contentContext(.addCommentModel(model: currentModel, context))
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
            HostSelectorView(location: $threadLocation,
                             model: currentModel)
            .attach({
                pager.reset()
            }, at: \.fetch)
            
            Spacer()
        }
        .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
        .offset(x: (Device.isExpandedLayout) ? -2 : 0, y: 0)
    }
}
