//
//  HeaderCardAvatarView.swift
//  Loom
//
//  Created by PEXAVC on 7/26/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct HeaderCardAvatarView: View {
    @Environment(\.contentContext) var context
    
    @GraniteAction<Void> var tappedThreadLine
    @GraniteAction<Void> var longPressThreadLine
    
    var postView: FederatedPostResource? {
        context.postModel
    }
    
    var commentView: FederatedCommentResource? {
        context.commentModel
    }
    
    typealias Crumb = (String, FederatedPerson)
    let crumbs: [Crumb]
    
    let showAvatar: Bool
    
    let size: AvatarView.Size
    
    let showThreadLine: Bool
    
    let shouldCollapse: Bool
    
    var isAdmin: Bool {
        postView?.creator.admin == true && commentView == nil
    }
    
    var isOP: Bool {
        guard let poster = postView?.creator else {
            return false
        }
        
        return commentView?.creator.equals(poster) == true
    }
    
    var isBot: Bool {
        context.person?.bot_account == true
    }
    
    var avatarBorderColor: Color {
        if isAdmin {
            return .red.opacity(0.8)
        } else if isOP {
            return .blue.opacity(0.8)
        } else {
            return .clear
        }
    }
    
    var isProminent: Bool {
        isAdmin || isOP
    }
    
    init(crumbs: [FederatedCommentResource] = [],
         showAvatar: Bool = true,
         size: AvatarView.Size = .small,
         showThreadLine: Bool = true,
         shouldCollapse: Bool = false) {
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        self.showAvatar = showAvatar
        self.size = size
        self.showThreadLine = showThreadLine
        self.shouldCollapse = shouldCollapse
    }
    
    var body: some View {
        VStack(spacing: .layer3) {
            if showAvatar {
                AvatarView(context.person,
                           size: size)
                .overlay(Circle()
                    .stroke(avatarBorderColor, lineWidth: 1.0))
            }
            
            if !shouldCollapse {
                if showThreadLine {
                    GeometryReader { proxy in
                        HStack(spacing: 0) {
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: 1.5)
                                    .cornerRadius(8)
                                    .foregroundColor((isProminent ? avatarBorderColor.opacity(0.7) : .foreground.opacity(0.3)))
                                
                                if isBot {
                                    Text("🤖")
                                        .font(.title2)
                                        .padding(.top, .layer3)
                                        .offset(y: 2)
                                } else {
                                    Spacer().frame(height: 2)
                                }
                            }
                            .frame(height: proxy.size.height)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .modifier(TapAndLongPressModifier(tapAction: {
                            tappedThreadLine.perform()
                        }, longPressAction: {
                            longPressThreadLine.perform()
                        }))
                    }
                } else {
                    Spacer()
                    
                    if isBot {
                        Text("🤖")
                            .font(.title2)
                            .padding(.top, .layer3)
                            .offset(y: 2)
                    }
                }
            }
        }
        .frame(width: size.frame)
    }
}
