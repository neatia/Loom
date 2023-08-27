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
    
    //Mod removal
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
        if isDeleted {
            return .deleted
        } else if isRemoved {
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
                                replyModel()
                            }, at: \.replyToContent)
                            .attach({
                                showThreadDrawer(model)
                            }, at: \.goToThread)
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
                        showThreadDrawer(model)
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
                 disabled: context.isPreview || context.isScreenshot) {
            
            replyModel()
        }
        .task {
            self.model = context.commentModel
            self.postView = context.postModel
            
            //Experiment
            interact?
                .listen(.bubble(context.id)) { value in
                    if let interact = value as? AccountService.Interact.Meta {
                        switch interact.intent {
                        case .deleteComment(let model):
                            guard model.id == context.commentModel?.id else { return }
                            self.model = model.updateDeleted()
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
                                       model: model) { (updatedModel, replyModel) in
                
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
    
    func replyModel() {
        guard let model else { return }
        
        ModalService
            .shared
            .showReplyCommentModal(isEditing: false,
                                   model: model) { (updatedModel, replyModel) in
            
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
}

extension CommentCardView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: .layer3) {
            #if os(macOS)
            contentBody
                .onTapGesture {
                    guard context.isPreview == false, model?.replyCount ?? 0 > 0 else { return }
                    GraniteHaptic.light.invoke()
                    expandReplies.toggle()
                }
            #else
            contentBody
            #endif
            FooterView(showScores: config.state.showScores)
                .attach({ id in
                    guard let model else { return }
                    showThreadDrawer(model)
                }, at: \.showComments)
                .attach({ model in
                    replyModel()
                }, at: \.replyComment)
        }
        .censor(shouldCensor, kind: censorKind, isComment: true)
        .onTapIf(Device.isExpandedLayout || shouldCensor) {
            guard context.isPreview else {
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
        .routeIf(Device.isExpandedLayout == false && context.isPreview,
                 window: .resizable(600, 500)) {
            //prevent type erasure
            PostDisplayView(context: _context)
        } with : { router }
    }
    
    var contentBody: some View {
        Group {
            if let model {
                if context.isPreview {
                    ScrollView(showsIndicators: false) {
                        MarkdownView(text: model.comment.content)
                            .fontGroup(CommentFontGroup())
                            .markdownViewRole(.editor)
                    }
                    .frame(height: 120)
                    .padding(.bottom, .layer3)
                } else {
                    MarkdownView(text: model.comment.content)
                        .fontGroup(CommentFontGroup())
                        .markdownViewRole(.editor)
                        .padding(.bottom, .layer3)
                        // This modifier causes a malloc crash on modal sheet previews
                        .modifier(TapAndLongPressModifier(tapAction: {
                            guard model.replyCount > 0 else { return }
                            GraniteHaptic.light.invoke()
                            expandReplies.toggle()
                        }, longPressAction: {
                            GraniteHaptic.light.invoke()
                            showThreadDrawer(model)
                        }))
                }
            } else {
                EmptyView()
            }
        }
    }
}

extension CommentCardView {
    func showThreadDrawer(_ model: CommentView?) {
        if parentModel == nil {
            ModalService
                .shared
                .showThreadDrawer(commentView: model,
                                  context: context)
        } else if let model {
            showDrawer.perform(model)
        }
    }
}
