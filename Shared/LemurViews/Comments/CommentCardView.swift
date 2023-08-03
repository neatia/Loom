import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI
import MarkdownView

struct CommentCardView: View {
    @Environment(\.graniteEvent) var interact
    
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<(CommentView, ((Comment) -> Void))> var reply
    
    @Relay var config: ConfigService
    
    @State var model: CommentView
    var postView: PostView? = nil
    
    //TODO: env. props
    var shouldRouteCommunity: Bool = true
    var shouldLinkToPost: Bool = false
    var parentModel: CommentView? = nil
    var isInline: Bool = false
    var isPreview: Bool = false
    var showAvatar: Bool = true
    var isBookmark: Bool = false
    
    let style: FeedStyle = .style2
    
    @State var minHeight: CGFloat = 100
    @State var expandReplies: Bool = false
    @State var refreshThread: Bool = false
    
    var censorBot: Bool {
        model.creator.bot_account && config.state.showBotAccounts == false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            switch style {
            case .style1:
                HeaderView(model,
                           shouldRouteCommunity: shouldRouteCommunity,
                           shouldRoutePost: shouldLinkToPost,
                           badge: shouldLinkToPost ? (postView == nil ? .noBadge : .post(postView!)) : nil)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
                content
                    .padding(.leading, .layer3 + AvatarView.containerPadding)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
            case .style2:
                HStack(spacing: .layer3) {
                    HeaderCardAvatarView(model, badge: (postView == nil ? .noBadge : .post(postView!)), showAvatar: showAvatar)
                    VStack(alignment: .leading, spacing: 2) {
                        HeaderCardView(model, badge: shouldLinkToPost ? (postView == nil ? nil : .post(postView!)) : nil)
                            .graniteEvent(interact)
                        content
                    }
                }
                .padding(.trailing, .layer3)
            }
            
            if expandReplies {
                Divider()
                    .padding(.top, .layer5)
                
                ThreadView(model: model, postView: postView, isModal: false, isInline: true)
                    .attach({ model in
                        reply.perform(model)
                    }, at: \.reply)
                    .attach({ model in
                        showDrawer.perform(model)
                    }, at: \.showDrawer)
                    .id(refreshThread)
            }
        }
        .padding(.top, .layer5)
        .padding(.bottom, expandReplies ? 0 : .layer5)
        .padding(.leading, .layer3)
        .onSwipe(edge: .trailing,
                 icon: "arrowshape.turn.up.backward.fill",
                 iconColor: Brand.Colors.babyBlue,
                 backgroundColor: .alternateBackground,
                 disabled: isPreview || isBookmark) {
            reply.perform((model, { model in
                self.model = self.model.incrementReplyCount()
                if expandReplies == false {
                    expandReplies = true
                } else {
                    refreshThread.toggle()
                }
            }))
        }
        .transaction { tx in
            tx.animation = nil
        }
    }
}

extension CommentCardView {
    var content: some View {
        VStack(alignment: .leading, spacing: .layer3) {
            #if os(macOS)
//            contentBody
//                .routeIf(model.replyCount > 0, style: .init(size: .init(600, 500))) {
//                    ThreadView(model: model)
//                }
            contentBody
                .censor(censorBot, kind: .bot)
                .padding(.top, censorBot ? .layer2 : 0)
                .onTapGesture {
                    guard isPreview == false, model.replyCount > 0 else { return }
                    GraniteHaptic.light.invoke()
                    expandReplies.toggle()
                }
            #else
            if isPreview {
                contentBody
                    .censor(censorBot, kind: .bot)
                    .padding(.top, censorBot ? .layer2 : 0)
            } else {
                contentBody
                    .censor(censorBot, kind: .bot)
                    .padding(.top, censorBot ? .layer2 : 0)
                .contentShape(Rectangle())
                .modifier(TapAndLongPressModifier(tapAction: {
                    guard isPreview == false, model.replyCount > 0 else { return }
                    GraniteHaptic.light.invoke()
                    expandReplies.toggle()
                }, longPressAction: {
                    guard model.replyCount > 0 else { return }
                    GraniteHaptic.light.invoke()
                    showDrawer.perform(model)
                }))
            }
            #endif
            FooterView(model, postView: postView, style: self.style)
                .attach({ id in
                    guard isPreview == false else { return }
                    showDrawer.perform(model)
                }, at: \.showComments)
                .attach({
                    //TODO: Change hard code to enum?
                    self.minHeight = self.minHeight == 100 ? 300 : 100
                }, at: \.expand)
        }
        .padding(.leading, style == .style1 ? (CGFloat.layer3 + CGFloat.layer2 + AvatarView.containerPadding) : 0)
        .overlayIf(style == .style1) {
            GeometryReader { proxy in
                Rectangle()
                    .frame(width: 2,
                           height: proxy.size.height)
                    .cornerRadius(8)
                    .opacity(0.5)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentBody: some View {
        Group {
            if isPreview {
                ScrollView {
                    MarkdownView(text: model.comment.content)
                        .markdownViewRole(.editor)
                }
                .frame(height: 120)
            } else {
                
                MarkdownView(text: model.comment.content)
                    .markdownViewRole(.editor)
            }
        }
//        HStack {
//
//            //            Markdown(content: .constant(model.comment.content),
//            //                     theme: colorScheme)
//            //                .markdownStyle(
//            //                    MarkdownStyle(
//            //                    padding: 0,
//            //                    paddingTop: 0,
//            //                    paddingBottom: 0,
//            //                    paddingLeft: 0,
//            //                    paddingRight: 0,
//            //                    size: Device.isMacOS == false ? .el2 : .normal
//            //                  ))
//            //                .frame(maxWidth: .infinity, minHeight: minHeight)
//            //            VStack(alignment: .leading, spacing: 0) {
//            //                Text(model.comment.content)
//            //                    .font(.headline.bold())
//            //                    .opacity(0.9)
//            //            }
//
//            Spacer()
//        }
    }
    
    
}
