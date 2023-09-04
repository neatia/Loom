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
import FederationKit

//TODO: merge with SidebarCardView
struct CommunityCardView: View {
    @Environment(\.graniteRouter) var router
    @GraniteAction<(FederatedCommunityResource, FederatedData?)> var viewCommunity
    
    
    var model: FederatedCommunityResource
    //TODO: centralize this at a higher level
    //since this component is used for many case scenarios
    var shouldRoute: Bool = false
    var showCounts: Bool = true
    var fullWidth: Bool = false
    var outline: Bool = false
    var style: CardStyle = .style1
    var federatedData: FederatedData? = nil
    
    var instanceType: FederatedInstanceType {
        model.community.instanceType
    }
    
    var hasSubCommunities: Bool {
        switch instanceType {
        case .rss, .mastodon:
            return false
        default:
            return true
        }
    }
    
    var peerHost: String? {
        if federatedData?.host == FederationKit.host {
            return nil
        } else {
            return federatedData?.host
        }
    }
    
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
                    
                    if hasSubCommunities {
                        Text("!"+model.community.name)
                            .font(.subheadline)
                            .cornerRadius(4)
                        Text("\(peerHost ?? "")@" + model.community.actor_id.host)
                            .font(.caption2)
                            .lineLimit(1)
                            .padding(.horizontal, .layer1)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(4)
                    } else {
                        Text(model.community.name)
                            .font(.subheadline)
                            .cornerRadius(4)
                        Text("•")
                            .font(.footnote)
                            .padding(.horizontal, .layer1)
                            .foregroundColor(.foreground.opacity(0.5))
                        InstanceSymbolView(instanceType)
                    }
                    
                }
                .padding(.top, 2)//nitpick
                
                
                Spacer()
            }
            .contentShape(Rectangle())
            .offset(y: .layer1)//nitpick
            .scrollOnOverflow()
            .onTapGesture {
                routeFederatedCommunityResource()
            }
            
            Menu {
                Button {
                    routeFederatedCommunityResource()
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
                    if hasSubCommunities {
                        HStack {
                            Text("\(subscribers) COMMUNITY_SUBSCRIBERS")
                                .font(.headline.bold())
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: .layer1) {
                        Text(model.community.title)
                            .font(showCounts ? .headline.bold() : .footnote.bold())
                            .lineLimit(1)
                            .cornerRadius(4)
                        
                        Spacer()
                    }//.scrollOnOverflow()
                    
                    if hasSubCommunities {
                        Group {
                            HStack(spacing: .layer1) {
                                Text("!"+model.community.name)
                                    .font(.subheadline)
                                Text("\(peerHost ?? "")@" + model.community.actor_id.host)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .padding(.vertical, .layer1)
                                    .padding(.horizontal, .layer1)
                                    .background(Color.tertiaryBackground)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                    } else {
                        HStack(spacing: .layer1) {
                            Text(model.community.name)
                                .font(.subheadline)
                        }
                        InstanceSymbolView(instanceType)
                    }
                }
                .offset(y: .layer1)
                .onTapGesture {
                    routeFederatedCommunityResource()
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
                                item.perform(withItems: [""])
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
            .frame(maxWidth: fullWidth ? .infinity : ContainerConfig.iPhoneScreenWidth * 0.9, maxHeight: 88)
            .background(Color.secondaryBackground)
            .cornerRadius(8)
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
    func routeFederatedCommunityResource() {
        let community = model.community
        GraniteHaptic.light.invoke()
        
        if Device.isExpandedLayout || shouldRoute == false {
            viewCommunity.perform((model, federatedData))
        } else {
            router.push {
                Feed(community, federatedData: federatedData)
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
        CommunityCardView(model: .init(community: .mock, subscribed: .notSubscribed, blocked: false, counts: .init(id: "0", community_id: 0, subscribers: 0, posts: 0, comments: 0, published: "", users_active_day: 0, users_active_week: 0, users_active_month: 0, users_active_half_year: 0, hot_rank: 0)))
    }
}
#endif
