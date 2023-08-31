import Foundation
import SwiftUI
import Granite
import GraniteUI
import MarkdownView
import FederationKit

struct CommentCardView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    @Environment(\.graniteEvent) var interact
    @GraniteAction<FederatedCommunity> var viewCommunity
    
    @GraniteAction<FederatedCommentResource> var showDrawer
    
    @Relay var config: ConfigService
    @Relay var layout: LayoutService
    @Relay(.silence) var content: ContentService
    
    @State var model: FederatedCommentResource?
    @State var postView: FederatedPostResource? = nil
    
    var currentModel: FederatedCommentResource? {
        model ?? context.commentModel
    }
    
    //Viewing kind
    @State var collapseView: Bool = false
    @State var expandReplies: Bool = false
    @State var refreshThread: Bool = false
    
    //TODO: env. props?
    var parentModel: FederatedCommentResource? = nil
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
                    .attach({
                        showThreadDrawer(model)
                    }, at: \.goToThread)
                    .contentContext(.addCommentModel(model: model, context))
                    .padding(.trailing, padding.trailing)
                    .padding(.bottom, .layer3)
                
                if model != nil {
                    contentView
                        .padding(.trailing, padding.trailing)
                        .padding(.bottom, .layer3)
                }
            case .style2:
                HStack(spacing: .layer3) {
                    HeaderCardAvatarView(showAvatar: showAvatar,
                                         shouldCollapse: collapseView)
                        .attach({
                            guard let currentModel,
                                  currentModel.replyCount > 0 else { return }
                            GraniteHaptic.light.invoke()
                            expandReplies.toggle()
                        }, at: \.tappedThreadLine)
                        .attach({
                            guard let currentModel,
                                  currentModel.replyCount > 0 else { return }
                            GraniteHaptic.light.invoke()
                            showThreadDrawer(currentModel)
                        }, at: \.longPressThreadLine)
                    VStack(alignment: .leading, spacing: 2) {
                        HeaderCardView(shouldRoutePost: self.shouldLinkToPost,
                                       shouldCollapse: collapseView)
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
                            .attach({
                                guard context.viewingContext == .postDisplay || context.viewingContext == .thread else { return }
                                GraniteHaptic.light.invoke()
                                collapseView.toggle()
                            }, at: \.tapped)
                            .graniteEvent(interact)
                            //Since the model could get updated (removal/deletion)
//                            .contentContext(.addCommentModel(model: currentModel, context))
                        
                        if !collapseView,
                           model != nil {
                            contentView
                        }
                    }
                }
                .padding(.trailing, padding.trailing)
            }
            
            if !collapseView,
               expandReplies {
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
            bottom = expandReplies && !collapseView ? 0 : .layer5
            trailing = .layer3
        }
         
        return .init(top: top,
                     leading: leading,
                     bottom: bottom,
                     trailing: trailing)
    }
    
    func editModel() {
        //This entire logic needs to be revised
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
        guard let currentModel else { return }
        
        ModalService
            .shared
            .showReplyCommentModal(isEditing: false,
                                   model: currentModel) { (updatedModel, replyModel) in
            
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
                guard let postView = await ContentUpdater.fetchFederatedPostResource(context.commentModel?.post) else {
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
            if let currentModel {
                if context.isPreview {
                    ScrollView(showsIndicators: false) {
                        MarkdownView(text: currentModel.comment.content)
                            .fontGroup(CommentFontGroup())
                            .markdownViewRole(.editor)
                    }
                    .frame(height: 120)
                    .padding(.bottom, .layer3)
                } else {
                    MarkdownView(text: currentModel.comment.content)
                        .fontGroup(CommentFontGroup())
                        .markdownViewRole(.editor)
                        .padding(.bottom, .layer3)

                }
            } else {
                EmptyView()
            }
        }
    }
}

extension CommentCardView {
    func showThreadDrawer(_ model: FederatedCommentResource?) {
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
