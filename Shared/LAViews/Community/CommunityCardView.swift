//
//  CommunityCardView.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import LemmyKit

//TODO: merge with SidebarCardView
struct CommunityCardView: View {
    @Environment(\.graniteRouter) var router
    @GraniteAction<Community> var viewCommunity
    
    
    var model: CommunityView
    var showCounts: Bool = true
    var fullWidth: Bool = false
    var outline: Bool = false
    var style: CardStyle = .style1
    
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
        Group {
            switch style {
            case .style1:
                style1View
            case .style2:
                style2View
            }
        }
    }
    
    var style2View: some View {
        HStack(spacing: .layer3) {
            AvatarView(model.iconURL, size: .mini, isCommunity: true)
            Group {
                HStack(spacing: .layer1) {
                    Text("!"+model.community.name)
                        .font(.subheadline)
                        .cornerRadius(4)
                    Text("@" + model.community.actor_id.host)
                        .font(.caption2)
                        .padding(.horizontal, .layer1)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(4)
                }
                
                
                Spacer()
            }
            .contentShape(Rectangle())
            .scrollOnOverflow()
            .offset(y: .layer1)
            .onTapGesture {
                routeCommunityView()
            }
            
            Menu {
                Button {
                    routeCommunityView()
                } label: {
                    Text("!\(model.community.name)")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
                    
            } label: {
                Image(systemName: "ellipsis")
                    .font(Device.isExpandedLayout ? .subheadline : .footnote.bold())
                    .frame(width: Device.isMacOS ? 16 : 24, height: 24)
                    .contentShape(Rectangle())
                    .foregroundColor(.foreground)
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .menuIndicator(.hidden)
            .frame(width: Device.isMacOS ? 20 : 24, height: 12)
        }
        .frame(maxHeight: AvatarView.Size.mini.frame)
        .padding(.layer3)
        .background(Color.secondaryBackground)
        .clipShape(Capsule())
    }
    
    var style1View: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer3) {
                AvatarView(model.iconURL, size: .large, isCommunity: true)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("\(subscribers) COMMUNITY_SUBSCRIBERS")
                            .font(.headline.bold())
                        
                        Spacer()
                    }
                    
                    HStack(spacing: .layer1) {
                        Text(model.community.title)
                            .font(showCounts ? .headline.bold() : .footnote.bold())
                            .lineLimit(1)
                            .cornerRadius(4)
                        
                        Spacer()
                    }//.scrollOnOverflow()
                    
                    HStack(spacing: .layer1) {
                        Text("!"+model.community.name)
                            .font(.subheadline)
                            .cornerRadius(4)
                        Text("@" + model.community.actor_id.host)
                            .font(.caption2)
                            .padding(.vertical, .layer1)
                            .padding(.horizontal, .layer1)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                    .scrollOnOverflow()
                }
                
                if fullWidth {
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
                    .padding(.trailing, .layer2)
                    #else
                    Menu {
                        ForEach(NSSharingService
                            .sharingServices(forItems: [""]),
                                id: \.title) { item in
                            Button(action: {
                                print(model.community.actor_id)
                    //                                        item.perform(withItems: [""])
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
            }
            .padding(.layer3)
            .foregroundColor(.foreground)
            .background(Color.secondaryBackground)
            .cornerRadius(8)
            .frame(maxWidth: fullWidth ? .infinity : ContainerConfig.iPhoneScreenWidth * 0.9, maxHeight: 88)
            .outlineIf(outline)
            
            if showCounts {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .layer2) {
                        
                        VStack(alignment: .leading, spacing: .layer2) {
                            HStack(spacing: .layer2) {
                                Text("TITLE_USERS")
                                    .font(.headline.bold())
                                    .foregroundColor(.foreground)
                            }
                            HStack(spacing: .layer2) {
                                VStack(alignment: .center, spacing: 0) {
                                    Text(usersPerDay+" ")
                                        .font(.footnote.bold())
                                        .foregroundColor(.foreground)+Text("UNIT_DAY")
                                        .font(.caption)
                                        .foregroundColor(.foreground)
                                }
                                .padding(.vertical, .layer1)
                                .padding(.horizontal, .layer2)
                                .background(Color.tertiaryBackground.opacity(0.9))
                                .cornerRadius(4)
                                
                                VStack(alignment: .center, spacing: 0) {
                                    Text(usersPerMonth+" ")
                                        .font(.footnote.bold())
                                        .foregroundColor(.foreground)+Text("UNIT_WEEK")
                                        .font(.caption)
                                        .foregroundColor(.foreground)
                                }
                                .padding(.vertical, .layer1)
                                .padding(.horizontal, .layer2)
                                .background(Color.tertiaryBackground.opacity(0.9))
                                .cornerRadius(4)
                                
                                VStack(alignment: .center, spacing: 0) {
                                    Text(usersPerMonth+" ")
                                        .font(.footnote.bold())
                                        .foregroundColor(.foreground)+Text("UNIT_MONTH")
                                        .font(.caption)
                                        .foregroundColor(.foreground)
                                }
                                .padding(.vertical, .layer1)
                                .padding(.horizontal, .layer2)
                                .background(Color.tertiaryBackground.opacity(0.9))
                                .cornerRadius(4)
                            }
                        }
                        
                        statsView
                        
                        if fullWidth {
                            Spacer()
                        }
                    }//hstack counts end
                }
                .padding(.top, .layer2)
            }
        }
    }
    
    var statsView: some View {
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
    }
}

//MARK: Actions

extension CommunityCardView {
    func routeCommunityView() {
        let community = model.community
        GraniteHaptic.light.invoke()
        if Device.isExpandedLayout {
            viewCommunity.perform(community)
        } else {
            router.push {
                Feed(community)
            }
        }
    }
}


#if DEBUG
struct CommunityCard_Previews : PreviewProvider {
    /*
     posts, comments, subscribers
     active day/week/month/halfyear
     */
    static var previews: some View {
        CommunityCardView(model: .init(community: .mock, subscribed: .notSubscribed, blocked: false, counts: .init(id: 0, community_id: 0, subscribers: 0, posts: 0, comments: 0, published: "", users_active_day: 0, users_active_week: 0, users_active_month: 0, users_active_half_year: 0, hot_rank: 0)))
    }
}
#endif
