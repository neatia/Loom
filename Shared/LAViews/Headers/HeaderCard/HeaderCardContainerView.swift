//
//  HeaderCardContainerView.swift
//  Loom
//
//  Created by PEXAVC on 9/2/23.
//

import FederationKit
import Foundation
import SwiftUI
import Granite

struct HeaderCardContainerView<Content: View>: View {
    @Environment(\.graniteEvent) var interact
    
    @GraniteAction<Void> var tappedThreadLine
    @GraniteAction<Void> var longPressThreadLine
    
    @GraniteAction<FederatedCommunity> var viewCommunity
    @GraniteAction<Void> var replyToContent
    @GraniteAction<Void> var goToThread
    @GraniteAction<Void> var edit
    @GraniteAction<Void> var tappedHeader
    
    var context: ContentContext
    var showAvatar: Bool
    var showThreadLine: Bool
    var shouldLinkToPost: Bool
    var collapseView: Bool
    var isCompact: Bool
    var content: () -> Content
    
    init(_ context: ContentContext,
         showAvatar: Bool,
         showThreadLine: Bool,
         shouldLinkToPost: Bool = false,
         collapseView: Bool = false,
         isCompact: Bool = false,
         @ViewBuilder content: @escaping () -> Content) {
        self.context = context
        self.showAvatar = showAvatar
        self.showThreadLine = showThreadLine
        self.shouldLinkToPost = shouldLinkToPost
        self.collapseView = collapseView
        self.isCompact = isCompact
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: .layer3) {
            if isCompact == false {
                HeaderCardAvatarView(showAvatar: showAvatar,
                                     showThreadLine: showThreadLine,
                                     shouldCollapse: collapseView)
                    .attach(tappedThreadLine, at: \.tappedThreadLine)
                    .attach(longPressThreadLine, at: \.longPressThreadLine)
            }
            
            VStack(alignment: .leading, spacing: context.isPost ? 0 : 2) {
                HeaderCardView(shouldRoutePost: self.shouldLinkToPost,
                               shouldCollapse: collapseView)
                    .attach(viewCommunity, at: \.viewCommunity)
                    .attach(replyToContent, at: \.replyToContent)
                    .attach(goToThread, at: \.goToThread)
                    .attach(edit, at: \.edit)
                    .attach(tappedHeader, at: \.tapped)
                
                if !collapseView {
                    content()
                }
            }
        }
        .contentContext(context)
    }
}
