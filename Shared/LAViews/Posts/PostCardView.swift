//
//  PostMiniView.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import LemmyKit
import Nuke
import NukeUI

struct PostCardView: View {
    @Environment(\.contentContext) var context
    @Environment(\.graniteRouter) var router
    @Environment(\.graniteEvent) var interact //account.center.interact
    @Environment(\.pagerMetadata) var contentMetadata
    
    @GraniteAction<PostView> var showContent
    @GraniteAction<PostView> var reply
    @GraniteAction<Community> var viewCommunity
    
    @Relay var config: ConfigService
    @Relay var layout: LayoutService
    
    @State var model: PostView?
    
    var topPadding: CGFloat = .layer6
    var bottomPadding: CGFloat = .layer6
    
    var linkPreviewType: LinkPreviewType = .large
    
    var censorNSFW: Bool {
        context.isNSFW && config.state.showNSFW == false
    }
    
    var censorBot: Bool {
        context.isBot && config.state.showBotAccounts == false
    }
    
    var censorBlocked: Bool {
        context.isBlocked
    }
    
    var censorRemoved: Bool {
        model?.post.removed ?? context.isRemoved
    }
    //TODO: differentiate between removed
    var censorDeleted: Bool {
        model?.post.deleted ?? context.isRemoved
    }
    
    var shouldCensor: Bool {
        censorRemoved || censorDeleted || censorBlocked || censorNSFW || censorBot
    }
    
    var censorKind: CensorView.Kind {
        if censorRemoved || censorDeleted {
            return .removed
        } else if censorNSFW {
            return .nsfw
        } else if censorBot {
            return .bot
        } else if censorBlocked {
            return .blocked
        } else {
            return .unknown
        }
    }
    
    //horizontal experience
    var isSelected: Bool {
        switch layout.state.feedContext {
        case .viewPost(let model):
            return context.postModel?.id == model.id
        default:
            return false
        }
    }
    
    var showAvatar: Bool {
        isCompact == false || context.viewingContext == .profile
    }
    
    //Desktop/iPad
    var isCompact: Bool {
        switch context.viewingContext {
        case .bookmarkExpanded:
            return true
        default:
            return false
        }
    }
    
    //primarily in SearchAllView
    var isPreview: Bool {
        context.viewingContext == .search
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch context.preferredStyle {
            case .style1:
                VStack(alignment: .leading, spacing: .layer3) {
                    HeaderView(badge: .noBadge)
                        .attach({ community in
                            viewCommunity.perform(community)
                        }, at: \.viewCommunity)
                        .attach({
                            editModel()
                        }, at: \.edit)
                    content
                    
                }
                .padding(.vertical, isPreview ? 0 : topPadding)
                .padding(.horizontal, .layer4)
            case .style2:
                HStack(spacing: .layer3) {
                    if isCompact == false {
                        HeaderCardAvatarView(showAvatar: showAvatar)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderCardView(badge: .noBadge, isCompact: isCompact)
                            .attach({ community in
                                viewCommunity.perform(community)
                            }, at: \.viewCommunity)
                            .attach({
                                editModel()
                            }, at: \.edit)
                            .graniteEvent(interact)
                        
                        content
                    }
                }
                .padding(padding)
                .overlayIf(isSelected,
                           overlay: Color.alternateBackground.opacity(0.3))
            }
        }
        .task {
            //Experiment
            interact?
                .listen(.bubble(context.id)) { value in
                    if let interact = value as? AccountService.Interact.Meta {
                        switch interact.intent {
                        case .removePost(let model):
                            guard model.id == context.postModel?.id else { return }
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
            top = isPreview ? (isCompact ? .layer3 : 0) : topPadding
            leading = .layer4
            bottom = isPreview ? (isCompact ? .layer3 : 0) : bottomPadding
            trailing = isCompact ? .layer3 : .layer4
        }
         
        return .init(top: top,
                     leading: leading,
                     bottom: bottom,
                     trailing: trailing)
    }
    
    func editModel() {
        ModalService
            .shared
            .showEditPostModal(context.postModel) { updatedModel in
                DispatchQueue.main.async {
                    model = updatedModel
                }
            }
    }
}

extension PostCardView {
    var content: some View {
        Group {
            switch context.preferredStyle {
            case .style1:
                contentBody
                    .padding(.bottom, .layer3)
            case .style2:
                contentBodyStacked
                    .censor(shouldCensor, kind: censorKind)
                    .padding(.bottom, shouldCensor ? .layer5 : 0)
            }
            
            switch censorKind {
            case .removed, .blocked:
                EmptyView()
            default:
                FooterView(showScores: config.state.showScores)
                    .attach({ model in
                        reply.perform(model)
                    }, at: \.reply)
            }
        }
        .fixedSize(horizontal: false, vertical: isPreview ? false : true)
    }
    
    @MainActor
    var contentBody: some View {
        
        HStack {
            if isPreview {
                ScrollView {
                    contentMetaBody
                }
            } else {
                contentMetaBody
            }
            
            Spacer()
            
            if let url = context.postModel?.thumbURL {
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.foreground.opacity(0.25))
                    
                    LazyImage(url: url) { state in
                        if let image = state.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(.foreground)
                        }
                    }
                }
                .censorAutoFit(shouldCensor, kind: censorKind)
                .frame(width: 60, height: 60)
                .cornerRadius(8.0)
                .clipped()
                .onTapGesture {
                    let model = model ?? context.postModel
                    guard let model else { return }
                    showContent.perform(model)
                }
            }
        }
        .padding(.bottom, .layer3)
    }
    
    var contentBodyStacked: some View {
        Group {
            if isPreview {
                ScrollView {
                    contentMetaBody
                }
            } else {
                contentMetaBody
                    .padding(.top, shouldCensor ? .layer3 : 0)
            }
            
            if contentMetadata != nil || context.hasURL {
                ContentMetadataView(metadata: contentMetadata,
                                    urlToOpen: context.postModel?.postURL,
                                    shouldLoad: context.hasURL)
                    .attach({
                        let model = model ?? context.postModel
                        guard let model else { return }
                        showContent.perform(model)
                    }, at: \.showContent)
                    .frame(maxWidth: Device.isExpandedLayout ? 350 : nil)
                    .padding(.top, .layer2)
                    .padding(.bottom, .layer6)
            }
        }
    }
    
    var contentMetaBody: some View {
        let model: PostView? = self.model ?? context.postModel
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(model?.post.name ?? "")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.foreground.opacity(0.9))
                Spacer()
            }
            .padding(.bottom, !context.hasBody && !context.hasURL ? .layer5 : 0)
            
            /*
             contentMetadata can be nil if showing bookmarks
             so checking posturl is better in this case
            */
            if model?.postURL == nil,
               let body = model?.post.body {
                let readMoreText: LocalizedStringKey = "MISC_READ_MORE"
                HStack(spacing: .layer2) {
                    Text(String(body.previewBody) + "\(body.count < 120 ? " " : "... ")")
                        .font(Device.isExpandedLayout ? .callout : .footnote)
                        .foregroundColor(.foreground.opacity(0.9)) + Text(body.count < 120 ? "" : readMoreText)
                        .font(Device.isExpandedLayout ? .callout.italic() : .footnote.italic())
                        .foregroundColor(.secondaryForeground.opacity(0.9))
                    Spacer()
                }
                .multilineTextAlignment(.leading)
                .padding(.top, .layer2)
                .padding(.bottom, .layer5)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapIf(Device.isExpandedLayout) {
            
            guard Device.isExpandedLayout,
                  let model = context.postModel else {
                GraniteHaptic.light.invoke()
                return
            }
            
            layout._state.wrappedValue.feedContext = .viewPost(model)
        }
        .routeIf(Device.isExpandedLayout == false,
                 window: .resizable(600, 500)) {
            //prevent type erasure
            PostDisplayView(context: _context, updatedModel: model)
        } with : { router }
    }
    
    var deletedPost: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("POST_DELETED")
                    .font(.body)
                    .padding(.bottom, .layer1)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.red.opacity(0.9))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

extension String {
    var previewBody: String {
        String(self.prefix(min(self.count, 120))).replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
