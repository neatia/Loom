//
//  CommunitySidebarCardView.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

//TODO: this should be merged with CommunityCardView

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct CommunitySidebarCardView: View {
    var model: FederatedCommunityResource
    var showCounts: Bool = true
    var fullWidth: Bool = true
    
    
    var subscribers: String {
        NumberFormatter.formatAbbreviated(model.counts.subscribers)
    }
    
    var posts: String {
        NumberFormatter.formatAbbreviated(model.counts.posts)
    }
    
    var comments: String {
        NumberFormatter.formatAbbreviated(model.counts.comments)
    }
    
    var usersPerDay: String {
        NumberFormatter.formatAbbreviated(model.counts.users_active_day)
    }
    
    var usersPerWeek: String {
        NumberFormatter.formatAbbreviated(model.counts.users_active_week)
    }
    
    var usersPerMonth: String {
        NumberFormatter.formatAbbreviated(model.counts.users_active_month)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: .layer3) {
                VStack(alignment: .leading, spacing: 0) {
                    if showCounts {
                        HStack {
                            Text("\(subscribers) COMMUNITY_SUBSCRIBERS")
                                .font(.footnote.bold())
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: .layer1) {
                        
                        Text(model.community.title)
                            .font(.caption.bold())
                            .cornerRadius(4)
                        Spacer()
                    }
                    
                    HStack(spacing: .layer1) {
                        Text("@" + model.community.actor_id.host)
                            .font(.caption2)
                            .padding(.vertical, 2)
                            .padding(.horizontal, .layer1)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(4)
                            .offset(x: -2)
                        
                        Spacer()
                    }
                }
                Spacer()
                
                #if os(iOS)
                Button {
                    GraniteHaptic.light.invoke()
                    ModalService.share(urlString: model.community.actor_id)
                } label: {
                    Image(systemName: "paperplane")
                        .font(.headline)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                #else
                Menu {
                    ForEach(NSSharingService
                        .sharingServices(forItems: [""]),
                            id: \.title) { item in
                        Button(action: {
                            item.perform(withItems: [model.community.actor_id])
                        }) {
                            Image(nsImage: item.image)
                            Text(item.title)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .contentShape(Rectangle())
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .frame(width: 24, height: 24)
                #endif
            }
            .padding(.layer2)
            .foregroundColor(.foreground)
            .background(Color.secondaryBackground)
            .cornerRadius(8)
            .padding(.bottom, .layer1)
            
            if showCounts {
                HStack(spacing: .layer2) {
                    AvatarView(model.iconURL, size: .mini, isCommunity: true)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: .layer2) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: .layer2) {
                                    Text("TITLE_USERS")
                                        .font(.footnote.bold())
                                        .foregroundColor(.foreground)
                                }
                                HStack(spacing: .layer2) {
                                    VStack(alignment: .center, spacing: 0) {
                                        Text(usersPerDay+" ")
                                            .font(.caption.bold())
                                            .foregroundColor(.foreground)+Text("UNIT_DAY")
                                            .font(.caption2)
                                            .foregroundColor(.foreground)
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, .layer1)
                                    .background(Brand.Colors.marble.opacity(0.9))
                                    .cornerRadius(4)
                                    
                                    VStack(alignment: .center, spacing: 0) {
                                        Text(usersPerMonth+" ")
                                            .font(.caption.bold())
                                            .foregroundColor(.foreground)+Text("UNIT_WEEK")
                                            .font(.caption2)
                                            .foregroundColor(.foreground)
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, .layer1)
                                    .background(Brand.Colors.marble.opacity(0.9))
                                    .cornerRadius(4)
                                    
                                    VStack(alignment: .center, spacing: 0) {
                                        Text(usersPerMonth+" ")
                                            .font(.caption.bold())
                                            .foregroundColor(.foreground)+Text("UNIT_MONTH")
                                            .font(.caption2)
                                            .foregroundColor(.foreground)
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, .layer1)
                                    .background(Brand.Colors.marble.opacity(0.9))
                                    .cornerRadius(4)
                                }
                            }
                            
                            
                            statsView
                            
                            if fullWidth {
                                Spacer()
                            }
                        }
                    }
                }//hstack counts end
            }
        }
    }
    
    var statsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: .layer2) {
                Text("TITLE_STATS")
                    .font(.footnote.bold())
                    .foregroundColor(.foreground)
            }
            HStack(spacing: .layer2) {
                VStack(alignment: .center, spacing: 0) {
                    Text(posts+" ")
                        .font(.caption.bold())
                        .foregroundColor(.foreground)+Text("TITLE_POSTS")
                        .font(.caption2)
                        .foregroundColor(.foreground)
                }
                .textCase(.lowercase)
                .padding(.vertical, 2)
                .padding(.horizontal, .layer1)
                .background(Brand.Colors.salmon.opacity(0.9))
                .cornerRadius(4)
                
                VStack(alignment: .center, spacing: 0) {
                    Text(comments+" ")
                        .font(.caption.bold())
                        .foregroundColor(.foreground)+Text("TITLE_COMMENTS")
                        .font(.caption2)
                        .foregroundColor(.foreground)
                }
                .textCase(.lowercase)
                .padding(.vertical, 2)
                .padding(.leading, .layer1)
                .background(Brand.Colors.salmon.opacity(0.9))
                .cornerRadius(4)
            }
        }
    }
}
