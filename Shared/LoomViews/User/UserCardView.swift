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
import LemmyKit

struct UserCardView: View {
    @Environment(\.graniteEvent) var interact
    
    var model: PersonView
    var isBlocked: Bool = false
    var fullWidth: Bool = false
    var showCounts: Bool = false
    
    var totalScore: String {
        NumberFormatter.formatAbbreviated(model.counts.totalScore)
    }
    
    var posts: String {
        NumberFormatter.formatAbbreviated(model.counts.post_count)
    }
    
    var comments: String {
        NumberFormatter.formatAbbreviated(model.counts.comment_count)
    }
    
    var postScore: String {
        NumberFormatter.formatAbbreviated(model.counts.post_score)
    }
    
    var commentScore: String {
        NumberFormatter.formatAbbreviated(model.counts.comment_score)
    }
    
    var body: some View {
        if fullWidth {
            fullWidthView
        } else {
            compactView
        }
    }
    
    var compactView: some View {
        VStack(spacing: 0) {
            AvatarView(model.person, size: .large)
                .padding(.bottom, .layer2)
            
            HStack {
                Spacer()
                
                VStack(spacing: 0) {
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
        .background(Color.secondaryBackground.opacity(0.8))
        .cornerRadius(8)
    }
    
    
    var fullWidthView: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer3) {
                AvatarView(model.person.avatarURL, size: .large)
                
                VStack(alignment: .leading, spacing: 0) {
                    if showCounts {
                        HStack {
                            Text("LABEL_SCORE \(totalScore)")
                                .font(.headline.bold())
                            
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
                            .font(.headline)
                            .cornerRadius(4)
                        Text("@" + model.person.actor_id.host)
                            .font(.caption)
                            .padding(.vertical, .layer1)
                            .padding(.horizontal, .layer1)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                CardActionsView(enableCommunityRoute: .constant(false),
                                person: model.person,
                                isBlocked: isBlocked || model.blocked)
                .graniteEvent(interact)
                .padding(.trailing, .layer3)
            }
            .padding(.layer3)
            .foregroundColor(.foreground)
            .background(Color.secondaryBackground.opacity(0.8))
            .cornerRadius(8)
            .frame(maxWidth: fullWidth ? .infinity : ContainerConfig.iPhoneScreenWidth * 0.9)
            .padding(.bottom, .layer2)
            
            if showCounts {
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
            }
        }
    }
}

#if DEBUG
struct UserCard_Previews : PreviewProvider {
    static var previews: some View {
        UserCardView(model: .init(person: .mock, counts: .init(id: 0, person_id: 0, post_count: 0, post_score: 0, comment_count: 0, comment_score: 0)))
            .frame(width: 120, height: 80)
    }
}
#endif
