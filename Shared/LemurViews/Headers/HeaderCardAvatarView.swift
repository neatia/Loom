//
//  HeaderCardAvatarView.swift
//  Lemur
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
    let badge: HeaderView.Badge
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
    
    init(_ model: PostView,
         crumbs: [PostView] = [],
         badge: HeaderView.Badge? = nil,
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
        
        self.badge = badge ?? .community(model.community.name)
        
        self.showAvatar = showAvatar
        
        self.size = size
        
        self.showThreadLine = showThreadLine
        
        Colors.update(model.community.name)
    }
    
    init(_ model: CommentView,
         crumbs: [CommentView] = [],
         badge: HeaderView.Badge? = nil,
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
        
        self.badge = badge ?? .none//((model.creator.domain != nil && model.creator.local == false) ? .host(model.creator.domain!) : .none)//.community(model.community.name)
        //Colors.update(model.creator.domain ?? model.community.name)
        
        self.size = size
        
        self.showThreadLine = showThreadLine
    }
    
    var body: some View {
        VStack(spacing: .layer3) {
            if showAvatar {
                AvatarView(person, size: size)
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
