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
    @Environment(\.graniteEvent) var interact
    @Environment(\.pagerMetadata) var contentMetadata
    
    @GraniteAction<Void> var showContent
    @GraniteAction<PostView> var reply
    @GraniteAction<Community> var viewCommunity
    
    @Relay var config: ConfigService
    @Relay var layout: LayoutService
    
    var model: PostView
    var isPreview: Bool = false
    var style: FeedStyle = .style1
    var showAvatar: Bool = true
    var isCompact: Bool = false
    var topPadding: CGFloat = .layer5
    var bottomPadding: CGFloat = .layer5
    
    var linkPreviewType: LinkPreviewType = .large
    
    var censorNSFW: Bool {
        model.post.nsfw && config.state.showNSFW == false
    }
    
    var censorBot: Bool {
        model.creator.bot_account && config.state.showBotAccounts == false
    }
    
    var censorBlocked: Bool {
        model.creator_blocked
    }
    
    var censorRemoved: Bool {
        model.post.removed
    }
    
    var shouldCensor: Bool {
        censorRemoved || censorBlocked || censorNSFW || censorBot
    }
    
    var censorKind: CensorView.Kind {
        if censorRemoved {
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
            return self.model.id == model.id
        default:
            return false
        }
    }
    
    var body: some View {
        Group {
            switch style {
            case .style1:
                VStack(alignment: .leading, spacing: .layer3) {
                    HeaderView(model, badge: .noBadge)
                        .attach({ community in
                            viewCommunity.perform(community)
                        }, at: \.viewCommunity)
                    content
                        .padding(.leading, .layer3 + AvatarView.containerPadding)
                    
                }
                .padding(.vertical, isPreview ? 0 : .layer4)
                .padding(.horizontal, .layer3)
            case .style2:
                HStack(spacing: .layer3) {
                    if isCompact == false {
                        HeaderCardAvatarView(model, showAvatar: showAvatar)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderCardView(model,
                                       badge: .noBadge,
                                       isCompact: isCompact)
                        .attach({ community in
                            viewCommunity.perform(community)
                        }, at: \.viewCommunity)
                        .graniteEvent(interact)
                        
                        content
                    }
                }
                .padding(.top, isPreview ? (isCompact ? .layer3 : 0) : topPadding)
                .padding(.bottom, isPreview ? (isCompact ? .layer3 : 0) : bottomPadding)
                .padding(.leading, .layer3)
                .padding(.trailing, isCompact ? .layer3 : .layer4)
                .backgroundIf(isSelected,
                              overlay: Color.accentColor.opacity(0.5))
            }
        }
    }
}

extension PostCardView {
    var content: some View {
        Group {
            switch style {
            case .style1:
                contentBody
                    .padding(.bottom, .layer3)
            case .style2:
                contentBodyStacked
                    .censor(shouldCensor, kind: censorKind)
                    .padding(.top, shouldCensor ? .layer2 : 0)
                    .padding(.bottom, .layer3)
            }

            if isPreview && !isCompact {
                Spacer()
            }
            switch censorKind {
            case .removed, .blocked:
                EmptyView()
            default:
                FooterView(postView: model,
                           commentView: nil,
                           showScores: config.state.showScores,
                           style: self.style)
                    .attach({ model in
                        reply.perform(model)
                    }, at: \.reply)
            }
        }
        .padding(.leading, style == .style1 ? (CGFloat.layer4 + CGFloat.layer2 + AvatarView.containerPadding) : 0)
//        .overlayIf(style == .style1) {
//            GeometryReader { proxy in
//                Rectangle()
//                    .frame(width: 2,
//                           height: proxy.size.height)
//                    .cornerRadius(8)
//                    .opacity(0.5)
//            }
//        }
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
            
            if let thumbUrl = model.post.thumbnail_url,
               let url = URL(string: thumbUrl) {
                
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
                .frame(width: 60, height: 60)
                .cornerRadius(8.0)
                .clipped()
                .onTapGesture {
                    showContent.perform()
                }
            }
        }
    }
    
    var contentBodyStacked: some View {
        Group {
            if isPreview {
                ScrollView {
                    contentMetaBody
                }
                .padding(.bottom, .layer2)
            } else {
                contentMetaBody
                    .padding(.bottom, .layer2)
            }
            
            if let contentMetadata {
                ContentMetadataView(metadata: contentMetadata, urlToOpen: model.postURL)
                    .frame(maxWidth: Device.isMacOS ? 350 : nil)
                    .padding(.bottom, .layer2)
            }
        }
    }
    
    var contentMetaBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(model.post.name)
                    .font(.body)
                    .padding(.bottom, model.post.body != nil ? .layer1 : 0)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.foreground.opacity(0.9))
                Spacer()
            }
            
            if model.postURL == nil,
               let body = model.post.body {
                let readMoreText: LocalizedStringKey = "MISC_READ_MORE"
                HStack(spacing: .layer2) {
                    Text(String(body.previewBody) + "\(body.count < 120 ? " " : "... ")")
                        .font(Device.isExpandedLayout ? .callout : .footnote)
                        .foregroundColor(.foreground) + Text(body.count < 120 ? "" : readMoreText)
                        .font(Device.isExpandedLayout ? .callout.italic() : .footnote.italic())
                        .foregroundColor(.secondaryForeground.opacity(0.9))
                    Spacer()
                }
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapIf(layout.state.style == .expanded) {
            layout._state.wrappedValue.feedContext = .viewPost(model)
        }
        .routeIf(layout.state.style == .compact || layout.state.style == .unknown,
                 style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
            PostDisplayView(model: model)
        }
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
