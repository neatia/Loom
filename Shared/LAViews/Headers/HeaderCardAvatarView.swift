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
    
    @GraniteAction<Int> var tappedDetail
    @GraniteAction<Int> var tappedCrumb
    
    let enableRoute: Bool
    
    let headline: String
    let subheadline: String?
    let subtitle: String?
    let avatarURL: URL?
    let time: Date?
    
    let id: Int
    let community: Community?
    
    typealias Crumb = (Int, Person)
    let crumbs: [Crumb]
    
    let person: Person?
    
    let showAvatar: Bool
    
    let size: AvatarView.Size
    
    let showThreadLine: Bool
    
    let postView: PostView?
    let commentView: CommentView?
    
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
    
    init(_ model: PostView,
         crumbs: [PostView] = [],
         showAvatar: Bool = true,
         size: AvatarView.Size = .small,
         showThreadLine: Bool = true) {
        self.headline = model.creator.name
        self.subheadline = model.post.local ? nil : model.creator.domain
        self.subtitle = nil
        
        self.avatarURL = model.avatarURL
        self.id = model.post.id
        self.community = model.community
        self.crumbs = []
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.enableRoute = true
        
        self.person = model.creator
        
        self.showAvatar = showAvatar
        
        self.size = size
        
        self.showThreadLine = showThreadLine
        
        self.postView = model
        self.commentView = nil
        
        Colors.update(model.community.name)
    }
    
    init(_ model: CommentView,
         postView: PostView? = nil,
         crumbs: [CommentView] = [],
         showAvatar: Bool = true,
         size: AvatarView.Size = .small,
         showThreadLine: Bool = true) {
        self.headline = model.creator.name
        self.subheadline = model.comment.local ? nil : model.creator.domain
        self.subtitle = nil
        
        self.avatarURL = model.avatarURL
        self.id = model.comment.id
        self.community = model.community
        self.crumbs = crumbs.map { ($0.comment.id, $0.creator) }
        
        self.time = model.counts.published.serverTimeAsDate
        
        self.enableRoute = false
        
        self.person = model.creator
        
        self.showAvatar = showAvatar
        
        self.size = size
        
        self.showThreadLine = showThreadLine
        
        self.postView = postView
        self.commentView = model
    }
    
    var body: some View {
        VStack(spacing: .layer3) {
            if showAvatar {
                AvatarView(person, size: size)
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
