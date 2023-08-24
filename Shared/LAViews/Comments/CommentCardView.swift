import Foundation
import SwiftUI
import LemmyKit
import Granite
import GraniteUI
import MarkdownView

struct CommentCardView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    @Environment(\.graniteEvent) var interact
    @GraniteAction<Community> var viewCommunity
    
    @GraniteAction<CommentView> var showDrawer
    
    @Relay var config: ConfigService
    @Relay var layout: LayoutService
    @Relay(.silence) var content: ContentService
    
    @State var model: CommentView?
    @State var postView: PostView? = nil
    
    var currentModel: CommentView? {
        model ?? context.commentModel
    }
    
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
    
    var isRemoved: Bool {
        currentModel?.comment.removed == true
    }
    
    var isDeleted: Bool {
        currentModel?.comment.deleted == true
    }
    
    var isBot: Bool {
        currentModel?.creator.bot_account == true
    }
    
    var shouldCensor: Bool {
        isRemoved || isDeleted || isBot
    }
    
    var censorKind: CensorView.Kind {
        if isRemoved || isDeleted {
            return .removed
        } else if isBot {
            return .bot
        } else {
            return .unknown
        }
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
            
            switch context.preferredStyle {
            case .style1:
                HeaderView(shouldRouteCommunity: shouldRouteCommunity,
                           shouldRoutePost: shouldLinkToPost)
                    .attach({ community in
                        viewCommunity.perform(community)
                    }, at: \.viewCommunity)
                    .attach({
                        editModel()
                    }, at: \.edit)
                    .contentContext(.addCommentModel(model: currentModel, context))
                    .padding(.trailing, padding.trailing)
                    .padding(.bottom, .layer3)
                
                contentView
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
                                editModel()
                            }, at: \.edit)
                            .graniteEvent(interact)
                            //Since the model could get updated (removal/deletion)
                            .contentContext(.addCommentModel(model: currentModel, context))
                        contentView
                    }
                }
                .padding(.trailing, padding.trailing)
            }
            
            if expandReplies {
                Divider()
                    .padding(.top, .layer5)
                
                ThreadView(updatedParentModel: currentModel,
                           isModal: false,
                           isInline: true)
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
                        self.refreshThread.toggle()
                    }
                }
            }
        }
        .task {
            self.model = context.commentModel
            self.postView = context.postModel
            
            //Experiment
            interact?
                .listen(.bubble(context.id)) { value in
                    if let interact = value as? AccountService.Interact.Meta {
                        switch interact.intent {
                        case .removeComment(let model):
                            guard model.id == context.commentModel?.id else { return }
                            self.model = model.updateRemoved()
                        default:
                            break
                        }
                    }
                }
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
    
    func editModel() {
        switch context.viewingContext {
        case .base,
             .bookmark,
             .bookmarkExpanded:
            
            //The function name doesn't seem to make sense
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
        .censor(shouldCensor, kind: censorKind, isComment: true)
        .onTapIf(Device.isExpandedLayout || shouldCensor) {
            
            guard isPreview else {
                if shouldCensor {
                    expandReplies.toggle()
                }
                return
            }
            
            guard layout.state.style == .expanded else {
                GraniteHaptic.light.invoke()
                return
            }
            
            Task.detached { @MainActor in
                guard let postView = await ContentUpdater.fetchPostView(context.commentModel?.post) else {
                    return
                }
                
                layout._state.wrappedValue.feedContext = .viewPost(postView)
            }
        }
        .routeIf(Device.isExpandedLayout == false && isPreview,
                 window: .resizable(600, 500)) {
            //prevent type erasure
            PostDisplayView(context: _context)
        } with : { router }
//        .overlayIf(context.feedStyle == .style1) {
//            GeometryReader { proxy in
//                Rectangle()
//                    .frame(width: 2,
//                           height: proxy.size.height)
//                    .cornerRadius(8)
//                    .opacity(0.5)
//            }
//        }
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
