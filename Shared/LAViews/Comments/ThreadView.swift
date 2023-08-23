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
    
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<Void> var closeDrawer
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
        breadCrumbs.last ?? context.commentModel
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
            }
            
            PagerScrollView(CommentView.self,
                            properties: .init(hideLastDivider: true,
                                              showFetchMore: false)) { commentView in
                CommentCardView(parentModel: currentModel,
                                isInline: isInline)
                    .attach({ model in
                        if isModal {
                            breadCrumbs.append(model)
                            pager.fetch()
                        } else {
                            showDrawer.perform(model)
                        }
                    }, at: \.showDrawer)
                    .contentContext(.addCommentModel(model: commentView, context))
            }
            .environmentObject(pager)
            .background(Color.alternateBackground)
        }
        .background(Color.background)
        .padding(.top, (Device.isMacOS || !isModal) ? 0 : .layer3)
        .task {
            pager.hook { page in
                let comments = await Lemmy
                    .comments(context.commentModel?.post,
                              comment: context.commentModel?.comment,
                              community: context.community?.lemmy,
                              page: page,
                              type: .all,
                              location: context.location)
                
                return comments.filter { $0.comment.id != context.id }
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
                       showScores: config.state.showScores)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                MarkdownView(text: context.commentModel?.comment.content ?? "")
                    .fontGroup(PostDisplayFontGroup())
                    .markdownViewRole(.editor)
            }
        }
    }
}
