import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI
import MarkdownView

struct CommentCardView: View {
    @GraniteAction<Community> var viewCommunity
    @Environment(\.graniteEvent) var interact
    
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<(CommentView, ((Comment) -> Void))> var reply
    
    @Relay var config: ConfigService
    
    @State var model: CommentView
    @State var postView: PostView? = nil
    
    //TODO: env. props
    var shouldRouteCommunity: Bool = true
    var shouldLinkToPost: Bool = true
    var parentModel: CommentView? = nil
    var isInline: Bool = false
    
    let style: FeedStyle = .style2
    var viewingContext: ViewingContext = .base
    
    @State var expandReplies: Bool = false
    @State var refreshThread: Bool = false
    
    var censorBot: Bool {
        model.creator.bot_account && config.state.showBotAccounts == false
    }
    
    var isBookmark: Bool {
        viewingContext.isBookmark
    }
    
    var isPreview: Bool {
        viewingContext == .search
    }
    
    var showAvatar: Bool {
        switch viewingContext {
        case .bookmarkExpanded, .profile:
            return false
        default:
            return true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            switch style {
            case .style1:
                HeaderView(model,
                           shouldRouteCommunity: shouldRouteCommunity,
                           shouldRoutePost: shouldLinkToPost,
                           badge: shouldLinkToPost ? (postView == nil ? .noBadge : .post(postView!)) : nil)
                .attach({ community in
                    viewCommunity.perform(community)
                }, at: \.viewCommunity)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
                content
                    .padding(.leading, .layer3 + AvatarView.containerPadding)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
            case .style2:
                HStack(spacing: .layer3) {
                    HeaderCardAvatarView(model, postView: postView, showAvatar: showAvatar)
                    VStack(alignment: .leading, spacing: 2) {
                        HeaderCardView(model,
                                       shouldRoutePost: self.shouldLinkToPost)
                            .attach({ community in
                                viewCommunity.perform(community)
                            }, at: \.viewCommunity)
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
            FooterView(postView: postView,
                       commentView: model,
                       showScores: config.state.showScores,
                       style: self.style)
                .attach({ id in
                    guard isPreview == false else { return }
                    showDrawer.perform(model)
                }, at: \.showComments)
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
                ScrollView(showsIndicators: false) {
                    MarkdownView(text: model.comment.content)
                        .markdownViewRole(.editor)
                }
                .frame(height: 120)
            } else {
                
                MarkdownView(text: model.comment.content)
                    .markdownViewRole(.editor)
            }
        }
    }
}
