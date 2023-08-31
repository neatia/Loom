//
//  UserCardView.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct UserCardView: View {
    @Environment(\.graniteEvent) var interact
    
    //To register menu touches effectively
    @GraniteAction<Void> var tapped
    
    var model: FederatedPersonResource
    var meta: AccountMeta?
    
    var isBlocked: Bool = false
    var fullWidth: Bool = false
    var showCounts: Bool = false
    var isSelected: Bool = false
    var canRemoveFromProfiles: Bool = false
    var style: CardStyle = .style1
    
    var totalScore: String {
        if let totalScore = meta?.resource.user.counts.totalScore {
            return totalScore.abbreviated
        }
        return model.counts.totalScore.abbreviated
    }
    
    var posts: String {
        if let posts = meta?.resource.user.counts.post_count {
            return posts.abbreviated
        }
        return model.counts.post_count.abbreviated
    }
    
    var comments: String {
        if let comments = meta?.resource.user.counts.comment_count {
            return comments.abbreviated
        }
        return model.counts.comment_count.abbreviated
    }
    
    var postScore: String {
        if let post_score = meta?.resource.user.counts.post_score {
            return post_score.abbreviated
        }
        return model.counts.post_score.abbreviated
    }
    
    var commentScore: String {
        if let comment_score = meta?.resource.user.counts.comment_score {
            return comment_score.abbreviated
        }
        return model.counts.comment_score.abbreviated
    }
    
    var body: some View {
        if fullWidth {
            fullWidthView
        } else {
            compactView
        }
    }
    
    var size: AvatarView.Size {
        switch style {
        case .style1:
            return .large
        case .style2:
            return .small
        }
    }
    
    var primaryFont: Font {
        switch style {
        case .style1:
            return .headline
        case .style2:
            return .subheadline
            
        }
    }
    
    var secondaryFont: Font {
        switch style {
        case .style1:
            return .caption
        case .style2:
            return .caption2
            
        }
    }
    
    var compactView: some View {
        VStack(spacing: 0) {
            AvatarView(model.person, size: size)
                .padding(.bottom, .layer2)
            
            HStack {
                Spacer()
                
                VStack(spacing: .layer1) {
                    Text(model.person.name)
                        .font(.footnote.bold())
                        .cornerRadius(4)
                    
                    Text("@" + model.person.actor_id.host)
                        .font(.caption)
                        .padding(.vertical, .layer1)
                        .padding(.horizontal, .layer1)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, .layer3)
        .background(Color.secondaryBackground)
        .cornerRadius(style == .style1 ? 8 : size.frame / 2)
    }
    
    
    var fullWidthView: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer3) {
                AvatarView(model.person.avatarURL, size: size)
                
                Group {
                    VStack(alignment: .leading, spacing: 0) {
                        if showCounts {
                            HStack {
                                Text("LABEL_SCORE \(totalScore)")
                                    .font(primaryFont)
                                
                                Spacer()
                            }
                        }
                        if let displayName = model.person.display_name {
                            HStack(spacing: .layer2) {
                                Text(displayName)
                                    .font(showCounts ? .headline.bold() : .footnote.bold())
                                    .cornerRadius(4)
                                
                                Spacer()
                            }
                        }
                        HStack(spacing: .layer2) {
                            Text("@" + model.person.name)
                                .font(primaryFont)
                                .cornerRadius(4)
                            Text("@" + model.person.actor_id.host)
                                .font(secondaryFont)
                                .padding(.vertical, .layer1)
                                .padding(.horizontal, .layer1)
                                .background(Color.tertiaryBackground)
                                .cornerRadius(4)
                            
                            Spacer()
                        }
                        .scrollOnOverflow()
                        .padding(.bottom, model.person.display_name == nil ? 0 : .layer3)
                    }
                    
                    Spacer()
                }.onTapGesture {
                    tapped.perform()
                }
                
                CardActionsView(enableCommunityRoute: .constant(false),
                                person: model.person,
                                isBlocked: isBlocked || model.blocked,
                                canRemoveFromProfiles: canRemoveFromProfiles)
                .graniteEvent(interact)
                .padding(.trailing, .layer3)
            }
            .frame(maxHeight: size.frame + (model.person.display_name == nil ? 0 : 24))
            .padding(.layer3)
            .foregroundColor(.foreground)
            .background(
                RoundedRectangle(cornerRadius: size.frame)
                    .strokeBorder(isSelected ? Color.secondaryForeground : Color.clear, lineWidth: 1)
            )
            .background(Color.secondaryBackground)
            .cornerRadius(style == .style1 ? 8 : size.frame)
            .frame(maxWidth: fullWidth ? .infinity : ContainerConfig.iPhoneScreenWidth * 0.9)
            
            if showCounts && style == .style1 {
                HStack(spacing: .layer2) {
                    
                    VStack(alignment: .leading, spacing: .layer2) {
                        HStack(spacing: .layer2) {
                            Text("TITLE_STATS")
                                .font(.headline.bold())
                                .foregroundColor(.foreground)
                        }
                        
                        HStack(spacing: .layer2) {
                            VStack(alignment: .center, spacing: 0) {
                                Text(posts+" ")
                                    .font(.footnote.bold())
                                    .foregroundColor(.foreground)+Text("TITLE_POSTS")
                                    .font(.caption)
                                    .foregroundColor(.foreground)
                            }
                            .textCase(.lowercase)
                            .padding(.vertical, .layer1)
                            .padding(.horizontal, .layer2)
                            .background(Brand.Colors.salmon.opacity(0.9))
                            .cornerRadius(4)
                            
                            VStack(alignment: .center, spacing: 0) {
                                Text(comments+" ")
                                    .font(.footnote.bold())
                                    .foregroundColor(.foreground)+Text("TITLE_COMMENTS")
                                    .font(.caption)
                                    .foregroundColor(.foreground)
                            }
                            .textCase(.lowercase)
                            .padding(.vertical, .layer1)
                            .padding(.horizontal, .layer2)
                            .background(Brand.Colors.salmon.opacity(0.9))
                            .cornerRadius(4)
                        }
                    }
                    Spacer()
                }//hstack counts end
                .padding(.top, .layer2)
            }
        }
    }
}

#if DEBUG
struct UserCard_Previews : PreviewProvider {
    static var previews: some View {
        UserCardView(model: .init(person: .mock, counts: .init(id: "0", person_id: "0", post_count: 0, post_score: 0, comment_count: 0, comment_score: 0)))
            .frame(width: 120, height: 80)
    }
}
#endif
