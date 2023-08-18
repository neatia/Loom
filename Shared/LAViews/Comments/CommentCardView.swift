import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI
import MarkdownView

struct CommentCardView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteEvent) var interact
    @GraniteAction<Community> var viewCommunity
    
    @GraniteAction<CommentView> var showDrawer
    @GraniteAction<(CommentView, ((CommentView) -> Void))> var edit
    @GraniteAction<(CommentView, ((CommentView) -> Void))> var reply
    
    @Relay var config: ConfigService
    @Relay(.silence) var content: ContentService
    
    @State var model: CommentView?
    @State var postView: PostView? = nil
    
    @State var expandReplies: Bool = false
    @State var refreshThread: Bool = false
    
    //TODO: env. props?
    var parentModel: CommentView? = nil
    var shouldRouteCommunity: Bool = true
    var shouldLinkToPost: Bool = true
    var isInline: Bool = false
    
    var censorBot: Bool {
        context.isBot && config.state.showBotAccounts == false
    }
    
    var isBookmark: Bool {
        context.viewingContext.isBookmark
    }
    
    var isPreview: Bool {
        context.viewingContext == .search
    }
    
    var showAvatar: Bool {
        switch context.viewingContext {
        case .bookmarkExpanded, .profile:
            return false
        default:
            return true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            switch context.feedStyle {
            case .style1:
                HeaderView(shouldRouteCommunity: shouldRouteCommunity,
                           shouldRoutePost: shouldLinkToPost)
                    .attach({ community in
                        viewCommunity.perform(community)
                    }, at: \.viewCommunity)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
                
                contentView
                    .padding(.leading, .layer3 + AvatarView.containerPadding)
                    .padding(.trailing, .layer3)
                    .padding(.bottom, .layer3)
            case .style2:
                HStack(spacing: .layer3) {
                    HeaderCardAvatarView(showAvatar: showAvatar)
                    VStack(alignment: .leading, spacing: 2) {
                        HeaderCardView(shouldRoutePost: self.shouldLinkToPost)
                            .attach({ community in
                                viewCommunity.perform(community)
                            }, at: \.viewCommunity)
                            .attach({
                                guard let model else { return }
                                switch context.viewingContext {
                                case .base:
                                    edit.perform((model, { updatedModel in
                                        DispatchQueue.main.async {
                                            self.model = updatedModel
                                        }
                                    }))
                                default:
                                    content.center.interact.send(ContentService.Interact.Meta(kind: .editComment(model, postView)))
                                }
                            }, at: \.edit)
                            .graniteEvent(interact)
                        contentView
                    }
                }
                .padding(.trailing, .layer3)
            }
            
            if expandReplies {
                Divider()
                    .padding(.top, .layer5)
                
                ThreadView(isModal: false, isInline: true)
                    .attach({ model in
                        reply.perform(model)
                    }, at: \.reply)
                    .attach({ model in
                        edit.perform(model)
                    }, at: \.edit)
                    .attach({ model in
                        showDrawer.perform(model)
                    }, at: \.showDrawer)
                    .id(refreshThread)
            }
        }
        .padding(.top, .layer5)
        .padding(.bottom, expandReplies ? 0 : .layer5)
        .padding(.leading, .layer4)
        .onSwipe(edge: .trailing,
                 icon: "arrowshape.turn.up.backward.fill",
                 iconColor: Brand.Colors.babyBlue,
                 backgroundColor: .alternateBackground,
                 disabled: isPreview || isBookmark) {
            
            guard let model else { return }
            
            reply.perform((model, { model in
                self.model = self.model?.incrementReplyCount()
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
        .task {
            self.model = context.commentModel
            self.postView = context.postModel
        }
    }
}

extension CommentCardView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: .layer3) {
            #if os(macOS)
            contentBody
                .censor(censorBot, kind: .bot)
                .padding(.top, censorBot ? .layer2 : 0)
                .onTapGesture {
                    guard isPreview == false, model?.replyCount ?? 0 > 0 else { return }
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
                    guard let model,
                          isPreview == false,
                          model.replyCount > 0 else { return }
                    GraniteHaptic.light.invoke()
                    expandReplies.toggle()
                }, longPressAction: {
                    guard let model,
                          model.replyCount > 0 else { return }
                    GraniteHaptic.light.invoke()
                    showDrawer.perform(model)
                }))
            }
            #endif
            FooterView(showScores: config.state.showScores)
                .attach({ id in
                    guard let model,
                          isPreview == false else { return }
                    showDrawer.perform(model)
                }, at: \.showComments)
        }
        .padding(.leading, context.feedStyle == .style1 ? (CGFloat.layer3 + CGFloat.layer2 + AvatarView.containerPadding) : 0)
        .overlayIf(context.feedStyle == .style1) {
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
                    MarkdownView(text: model?.comment.content ?? "")
                        .markdownViewRole(.editor)
                }
                .frame(height: 120)
            } else {
                
                MarkdownView(text: model?.comment.content ?? "")
                    .markdownViewRole(.editor)
            }
        }
    }
}
