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
import LemmyKit

struct HeaderCardAvatarView: View {
    @Environment(\.contentContext) var context
    
    @GraniteAction<Int> var tappedDetail
    @GraniteAction<Int> var tappedCrumb
    
    var postView: PostView? {
        context.postModel
    }
    
    var commentView: CommentView? {
        context.commentModel
    }
    
    typealias Crumb = (Int, Person)
    let crumbs: [Crumb]
    
    let showAvatar: Bool
    
    let size: AvatarView.Size
    
    let showThreadLine: Bool
    
    var isAdmin: Bool {
        postView?.creator.admin == true && commentView == nil
    }
    
    var isOP: Bool {
        guard let poster = postView?.creator else {
            return false
        }
        
        return commentView?.creator.equals(poster) == true
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
    
    init(crumbs: [CommentView] = [],
         showAvatar: Bool = true,
         size: AvatarView.Size = .small,
         showThreadLine: Bool = true) {
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        self.showAvatar = showAvatar
        self.size = size
        self.showThreadLine = showThreadLine
    }
    
    var body: some View {
        VStack(spacing: .layer3) {
            if showAvatar {
                AvatarView(context.person?.lemmy,
                           size: size)
                    .overlay(Circle()
                        .stroke(avatarBorderColor, lineWidth: 1.0))
            }
            
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    Rectangle()
                        .frame(width: 1.5,
                               height: proxy.size.height)
                        .cornerRadius(8)
                        .foregroundColor(.foreground.opacity(0.3))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: size.frame)
    }
}
