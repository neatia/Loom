import Foundation
import SwiftUI
//import NukeUI
import Granite
import GraniteUI
import LemmyKit
import MarkdownView

struct ThreadView: View {
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<Void> var closeDrawer
    @GraniteAction<(CommentView, ((Comment) -> Void))> var reply
    
    let model: CommentView
    var postView: PostView? = nil
    var isModal: Bool = true
    var isInline: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @Relay var modalService: ModalService
    
    @State var breadCrumbs: [CommentView] = []
    
    var comments: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    
    var currentModel: CommentView {
        breadCrumbs.last ?? model
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isModal {
                HeaderView(model, crumbs: breadCrumbs.reversed())
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
            
            PagerScrollView(CommentView.self) { comment in
                CommentCardView(model: comment,
                                postView: postView,
                                parentModel: currentModel,
                                isInline: isInline)
                    .attach({ model in
                        reply.perform(model)
                    }, at: \.reply)
                    .attach({ model in
                        if isModal {
                            breadCrumbs.append(model)
                            comments.fetch()
                        } else {
                            showDrawer.perform(model)
                        }
                    }, at: \.showDrawer)
            }
            .environmentObject(comments)
            .background(Color.alternateBackground)
        }
        .background(Color.background)
        .padding(.top, (Device.isMacOS || !isModal) ? 0 : .layer3)
        .task {
            comments.hook { page in
                let comments = await Lemmy
                    .comments(currentModel.post,
                              comment: currentModel.comment,
                              page: page,
                              type: .all)
                
                return comments.filter { $0.comment.id != currentModel.comment.id }
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
        VStack(alignment: .leading, spacing: .layer3) {
            #if os(iOS)
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.5)
                .modifier(TapAndLongPressModifier(tapAction: {
                }, longPressAction: {
                    GraniteHaptic.light.invoke()
                    closeDrawer.perform()
                }))
            #else
            contentBody
                .frame(maxHeight: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenHeight * 0.5)
            #endif
            
            FooterView(currentModel, postView: postView, isHeader: true)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                MarkdownView(text: currentModel.comment.content)
                    .markdownViewRole(.editor)
            }
        }
//        HStack {
////                Markdown(content: .constant(currentModel.comment.content),
////                         theme: colorScheme)
////                .markdownStyle(
////                    MarkdownStyle(
////                        padding: 0,
////                        paddingTop: 0,
////                        paddingBottom: 0,
////                        paddingLeft: 0,
////                        paddingRight: 0,
////                        size: Device.isMacOS ? .el1 : .el3
////                    ))
////                .frame(minHeight: 100, maxHeight: 300)
////                .id(currentModel.comment.id)
//
//            //            VStack(alignment: .leading, spacing: 0) {
//            //                Text(model.comment.content)
//            //                    .font(.title3.bold())
//            //                    .opacity(0.9)
//            //            }
//
//            Spacer()
//        }
    }
}
