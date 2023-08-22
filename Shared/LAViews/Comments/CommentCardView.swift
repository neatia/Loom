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
                    .padding(.trailing, padding.trailing)
                    .padding(.bottom, .layer3)
                
                contentView
                    .padding(.leading, .layer3 + AvatarView.containerPadding)
                    .padding(.trailing, padding.trailing)
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
                                case .base,
                                     .bookmark,
                                     .bookmarkExpanded:
                                    
                                    ModalService
                                        .shared
                                        .showReplyCommentModal(isEditing: true,
                                                               model: model) { updatedModel in
                                        
                                        DispatchQueue.main.async {
                                            self.model = updatedModel
                                        }
                                    }
                                default:
                                    ModalService
                                        .shared
                                        .showEditCommentModal(model,
                                                              postView: postView) { updatedModel in
                                            self.model = updatedModel
                                        }
                                }
                            }, at: \.edit)
                            .graniteEvent(interact)
                        contentView
                    }
                }
                .padding(.trailing, padding.trailing)
            }
            
            if expandReplies {
                Divider()
                    .padding(.top, .layer5)
                
                ThreadView(isModal: false, isInline: true)
                    .attach({ model in
                        showDrawer.perform(model)
                    }, at: \.showDrawer)
                    .id(refreshThread)
            }
        }
        .padding(.top, padding.top)
        .padding(.bottom, padding.bottom)
        .padding(.leading, padding.leading)
        .onSwipe(edge: .trailing,
                 icon: "arrowshape.turn.up.backward.fill",
                 iconColor: Brand.Colors.babyBlue,
                 backgroundColor: .alternateBackground,
                 disabled: isPreview || context.isScreenshot) {
            
            guard let model else { return }
            
            ModalService
                .shared
                .showReplyCommentModal(isEditing: false,
                                       model: model) { updatedModel in
                
                DispatchQueue.main.async {
                    self.model = self.model?.incrementReplyCount()
                    if expandReplies == false {
                        expandReplies = true
                    } else {
                        refreshThread.toggle()
                    }
                }
            }
        }
        .task {
            self.model = context.commentModel
            self.postView = context.postModel
        }
    }
    
    var padding: EdgeInsets {
        let top: CGFloat
        let leading: CGFloat
        let bottom: CGFloat
        let trailing: CGFloat
        
        if context.isScreenshot {
            top = .layer4
            leading = .layer4
            bottom = .layer4
            trailing = .layer4
        } else {
            top = .layer5
            leading = .layer4
            bottom = expandReplies ? 0 : .layer5
            trailing = .layer3
        }
         
        return .init(top: top,
                     leading: leading,
                     bottom: bottom,
                     trailing: trailing)
    }
}

extension CommentCardView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: .layer3) {
            #if os(macOS)
            contentBody
                .onTapGesture {
                    guard isPreview == false, model?.replyCount ?? 0 > 0 else { return }
                    GraniteHaptic.light.invoke()
                    expandReplies.toggle()
                }
            #else
            if isPreview {
                contentBody
            } else {
                contentBody
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
//        .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentBody: some View {
        Group {
            if isPreview {
                ScrollView(showsIndicators: false) {
                    MarkdownView(text: model?.comment.content ?? "")
                        .fontGroup(CommentFontGroup())
                        .markdownViewRole(.editor)
                }
                .frame(height: 120)
                .padding(.bottom, .layer3)
            } else if let content = model?.comment.content {
                MarkdownView(text: content)
                    .fontGroup(CommentFontGroup())
                    .markdownViewRole(.editor)
                    .padding(.bottom, .layer3)
            }
        }
    }
}
