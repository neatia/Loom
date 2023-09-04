import Foundation
import SwiftUI
import Granite
import GraniteUI
import MarkdownView
import FederationKit

struct CommentCardView: View {
    @Environment(\.graniteRouter) var router
    @Environment(\.graniteEvent) var interact
    
    /*
     Threads can have unlimited nested comment cards.
     We do not want to environment the context.
     Since they all have the potential
     of accessing the same key/value leading to
     unforeseen crashes/malloc issues
     
     Another potential update in the future is using
     Observed/EnvironmentObjects
     */
    var context: ContentContext
    
    @GraniteAction<FederatedCommunity> var viewCommunity
    
    @GraniteAction<FederatedCommentResource> var showDrawer
    
    @Relay var config: ConfigService
    @Relay var layout: LayoutService
    @Relay(.silence) var content: ContentService
    
    var currentModel: FederatedCommentResource? {
        updatedModel ?? context.commentModel
    }
    
    @State var updatedModel: FederatedCommentResource?
    @State var postView: FederatedPostResource? = nil
    
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
            
            switch context.feedStyle {
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
                        showThreadDrawer(currentModel)
                    }, at: \.goToThread)
                    .contentContext(.addCommentModel(model: currentModel, context))
                    .padding(.trailing, padding.trailing)
                    .padding(.bottom, .layer3)
                
                if currentModel != nil {
                    contentView
                        .padding(.trailing, padding.trailing)
                        .padding(.bottom, .layer3)
                }
            case .style2, .style3:
                HeaderCardContainerView(.addCommentModel(model: currentModel,
                                                         context),
                                        showAvatar: showAvatar,
                                        showThreadLine: (currentModel?.replyCount ?? 0) > 0,
                                        shouldLinkToPost: shouldLinkToPost,
                                        collapseView: collapseView) {
                    contentView
                }
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
                .attach(viewCommunity, at: \.viewCommunity)
                .attach({
                    replyModel()
                }, at: \.replyToContent)
                .attach({
                    showThreadDrawer(currentModel)
                }, at: \.goToThread)
                .attach({
                    editModel()
                }, at: \.edit)
                .attach({
                    guard context.viewingContext == .postDisplay || context.viewingContext.isThread else { return }
                    GraniteHaptic.light.invoke()
                    collapseView.toggle()
                }, at: \.tappedHeader)
                .padding(.trailing, padding.trailing)
            }
            
            if !collapseView,
               expandReplies {
                Divider()
                    .padding(.top, .layer5)
                
                /*
                 This can be an environmentValue, but there was an odd mem
                 acess issue. safer to pass as value for now, and then apply
                 the environment of the passed in context to the commentcards
                 spawned within
                 */
                ThreadView(context: .addCommentModel(model: currentModel,
                                                     context),
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
            setupListeners()
        }
        /*
         A listener
         
         update view states with actions
         executed by nested subviews
         
         Pros:
         - no need to pass down - Clean
         - no need for the parent view to re-draw - Performant
         */
        .onChange(of: currentModel) { _ in
            setupListeners()
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
        ModalService
            .shared
            .showEditCommentModal(currentModel,
                                  postView: context.postModel) { updatedModel in
                self.updatedModel = updatedModel
                self.expandReplies = false
            }
    }
    
    func replyModel() {
        guard let currentModel else { return }
        
        ModalService
            .shared
            .showReplyCommentModal(model: currentModel) { (updatedModel, replyModel) in
            
            DispatchQueue.main.async {
                self.updatedModel = self.currentModel?.incrementReplyCount()
                if expandReplies == false {
                    expandReplies = true
                } else {
                    self.refreshThread.toggle()
                }
            }
        }
    }
    
    func setupListeners() {
        //Experimenting with this approach of event handling vs. graniteactions
        interact?
            .listen(.bubble(context.id)) { value in
                if let interact = value as? AccountService.Interact.Meta {
                    switch interact.intent {
                    case .deleteComment(let model):
                        guard model.id == currentModel?.id else {
                            LoomLog("failed to update deleted state for bubbled event: \(model.id) != \(currentModel?.id) ", level: .debug)
                            return
                        }
                        LoomLog("Updating deleted state for bubbled event for deleted comment", level: .debug)
                        updatedModel = model.updateDeleted()
                        //expandReplies = false
                    default:
                        break
                    }
                }
            }
    }
}

extension CommentCardView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: .layer3) {
            if Device.isMacOS {
                contentBody
                    .onTapGesture {
                        guard context.isPreview == false, currentModel?.replyCount ?? 0 > 0 else { return }
                        GraniteHaptic.light.invoke()
                        expandReplies.toggle()
                    }
            } else {
                contentBody
            }
            
            FooterView(showScores: config.state.showScores)
                .attachAndClear({ model in
                    replyModel()
                }, at: \.replyComment)
                .contentContext(.addCommentModel(model: currentModel,
                                                 context))
        }
        .censor(shouldCensor, kind: censorKind, isComment: true)
    }
    
    var contentBody: some View {
        MarkdownContainerView(text: currentModel?.comment.content,
                              isPreview: context.isPreview,
                              kind: .comment)
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
