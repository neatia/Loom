//
//  FeedHamburgerView.swift
//  Loom
//
//  Created by PEXAVC on 8/21/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

extension Feed {
    var accountExpandedMenuView: some View {
        FeedHamburgerView(community: state.community,
                          communityView: state.communityView,
                          location: state.location,
                          peerLocation: state.peerLocation)
            .attach( { modalView in
                #if os(iOS)
                ModalService.shared.present(modalView)
                #else
                ModalService.shared.presentModal(modalView)
                #endif
            }, at: \.present)
            .attach( { meta in
                config
                    .center
                    .restart
                    .send(ConfigService
                        .Restart
                        .Meta(accountMeta: meta))
                
                DispatchQueue.main.async {
                    ModalService.shared.dismissAll()
                }
            }, at: \.switchAccount)
            .attach({
                ModalService.shared.presentSheet(detents: [.medium, .large]) {
                    LoginView(addToProfiles: true)
                        .attach({
                            ModalService.shared.dismissSheet()
                        }, at: \.cancel)
                }
            }, at: \.addProfile)
            .attach({
                GraniteHaptic.light.invoke()
                ModalService.shared.presentSheet(detents: [.medium, .large]) {
                    LoginView()
                        .attach({
                            ModalService.shared.dismissSheet()
                        }, at: \.cancel)
                }
            }, at: \.login)
            .attach({ location in
                fetchCommunity(state.community,
                               location: location,
                               reset: true)
            }, at: \.changeLocation)
            .id(account.state.meta)
            .padding(.top, headerPaddingTop)
    }
}

/*
 This is only viewable on mobile, adding a modalservice is safe, due
 to it being added on the Window level, versus the current view (macOS)
 */
struct FeedHamburgerView: View {
    @Environment(\.graniteRouter) var router
    
    @Environment(\.sideMenuVisible) var isVisible
    
    @GraniteAction<AnyGraniteModal> var present
    @GraniteAction<AccountMeta> var switchAccount
    @GraniteAction<Void> var addProfile
    @GraniteAction<Void> var login
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    //ExpandedView Only
    @GraniteAction<FederatedLocationType> var changeLocation
    
    //Conditional views
    @State var loomsIsActive: Bool = false
    @State var blockedListIsActive: Bool = false
    @State var profileIsActive: Bool = false
    @State var settingsIsActive: Bool = false
    
    //FeedMeta
    var community: FederatedCommunity?
    var communityView: FederatedCommunityResource?
    var location: FederatedLocationType
    var peerLocation: FederatedLocationType?
    var hasCommunityBanner: Bool {
        communityView?.community.banner != nil
    }
    //
    
    var accountMeta: AccountMeta? {
        account.state.meta
    }
    
    var displayName: String? {
        accountMeta?.person.display_name
    }
    
    var username: String? {
        accountMeta?.username
    }
    
    var actor_id: String? {
        accountMeta?.person.actor_id
    }
    
    var aggregates: FederatedPersonAggregates? {
        FederationKit.user()?.resource.user.counts
    }
    
    var postScore: String? {
        "\(aggregates?.post_score ?? 0)"
    }
    
    var commentScore: String? {
        "\(aggregates?.comment_score ?? 0)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                AvatarView(accountMeta?.avatarURL,
                           size: Device.isExpandedLayout ? .mini : .medium)
                
                if Device.isExpandedLayout {
                    AccountView()
                        .attach({
                            GraniteHaptic.light.invoke()
                            login.perform()
                        }, at: \.login)
                        .offset(y: hasCommunityBanner ? -1 : 0)
                        .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                        .padding(.vertical, hasCommunityBanner ? 4 : 0)
                        .backgroundIf(hasCommunityBanner) {
                            Color.background.opacity(0.75)
                                .cornerRadius(4)
                        }
                }
                
                Spacer()
                
                if Device.isExpandedLayout && community != nil {
                    FeedCommunityInfoMenuView(community: community,
                                              communityView: communityView,
                                              location: location,
                                              peerLocation: peerLocation)
                    .attach({ interact in
                        if account.isLoggedIn {
                            account
                                .center
                                .interact
                                .send(AccountService.Interact.Meta(intent: interact))
                        } else {
                            ModalService.shared.presentSheet {
                                LoginView()
                            }
                        }
                    }, at: \.interact)
                    .attach({ location in
                        changeLocation.perform(location)
                    }, at: \.changeLocation)
                } else {
                    switchAccountMenu
                }
            }
            .padding(.bottom, .layer2)
            .padding(.trailing, Device.isExpandedLayout ? 0 : .layer4)
            
            if Device.isExpandedLayout == false {
                
                if account.isLoggedIn {
                    loggedInViews
                }
                
                //General menu items
                VStack(spacing: .layer5 + 2) {
                    if account.isLoggedIn {
                        profileView
                        loomsView
                        blockedListView
                    } else {
                        loginView
                        loomsView
                    }
                    
                    
                    Spacer()
                    
                    setInstanceView
                    settingsView
                }
                .padding(.top, .layer6)
                .padding(.bottom, .layer2)
            }
        }
        .padding(.top, Device.isExpandedLayout ? .layer3 : .layer4)
        .padding(.bottom, Device.isExpandedLayout ? 0 : .layer4)
        .padding(.leading, Device.isExpandedLayout ? 0 : .layer5)
        .background(Device.isExpandedLayout ? Color.clear : Color.background)
    }
}


//MARK: Looms menu
extension FeedHamburgerView {
    var loomsView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    GraniteHaptic.light.invoke()
                    loomsIsActive.toggle()
                } label : {
                    Image(systemName: "applescript")
                        .font(.title3)
                        .foregroundColor(.foreground)
                    //TODO: localize
                    Text("Looms")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                        .padding(.leading, .layer1)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            if loomsIsActive {
                Divider()
                    .padding(.top, .layer4)
                
                LoomPickerView(trailingPadding: .layer4)
            }
        }
    }
}

//MARK: Switch account menu
extension FeedHamburgerView {
    var switchAccountMenu: some View {
        Menu {
            Button {
                GraniteHaptic.light.invoke()
                
                present
                    .perform(GraniteAlertView(mode: .sheet) {
                    
                        if account.state.profiles.isNotEmpty {
                            GraniteAlertAction {
                                VStack(spacing: .layer2) {
                                    ForEach(account.state.profiles) { profile in
                                        UserCardView(model: profile.person.asView(),
                                                     meta: profile,
                                                     fullWidth: true,
                                                     showCounts: true,
                                                     isSelected: profile.person.isMe,
                                                     canRemoveFromProfiles: true,
                                                     style: .style2)
                                        .attach({
                                            guard profile.person.isMe == false else { return }
                                            GraniteHaptic.light.invoke()
                                            switchAccount.perform(profile)
                                        }, at: \.tapped)
                                        .graniteEvent(account.center.interact)
                                        .padding(.horizontal, .layer4)
                                        
                                    }
                                }
                                .wrappedInScrollView(when: account.state.profiles.count > 3,
                                                     axis: .vertical)
                                .id(account.state.profiles)
                            }
                        }
                        
                        //TODO: Localize
                        GraniteAlertAction(title: "Add Account") {
                            addProfile.perform()
                        }
                        
                        GraniteAlertAction(title: "MISC_CANCEL")
                })
            } label: {
                //TODO: localize
                Text("Switch Account")
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            if account.isLoggedIn {
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                    account.center.logout.send()
                } label: {
                    Text("MISC_LOGOUT")
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                
                Button {
                    GraniteHaptic.light.invoke()
                    login.perform()
                } label: {
                    Text("AUTH_LOGIN")
                }
                .buttonStyle(PlainButtonStyle())
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .foregroundColor(.foreground)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .frame(width: 24, height: 24)
    }
}

//MARK: Logged in views
extension FeedHamburgerView {
    var hasDisplayName: Bool {
        displayName != nil
    }
    
    var loggedInViews: some View {
        Group {
            if let displayName {
                HStack(alignment: .bottom, spacing: .layer1) {
                    Text(displayName)
                        .font(.headline)
                        .lineLimit(1)
                        .cornerRadius(4)
                    
                    Spacer()
                }
                .padding(.bottom, .layer2)
            }
            
            if let username,
               let actor_id {
                HStack(alignment: .bottom, spacing: .layer1) {
                    Text(username)
                        .font(hasDisplayName ? .subheadline : .headline)
                        .cornerRadius(4)
                    Text("@" + actor_id.host)
                        .font(.caption2)
                        .padding(.vertical, .layer1)
                        .padding(.horizontal, .layer1)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(4)
                        .offset(y: .layer1 / 2)
                    
                    Spacer()
                }
                .padding(.bottom, .layer3)
            }
            
            if let postScore, let commentScore {
                HStack(alignment: .bottom, spacing: .layer1) {
                    Text(postScore)
                        .font(.subheadline)
                        .foregroundColor(.foreground)
                    
                    //TODO: localize
                    Text("Post score")
                        .font(.footnote)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Text("•")
                        .font(.footnote)
                        .padding(.horizontal, .layer1)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Text(commentScore)
                        .font(.subheadline)
                        .foregroundColor(.foreground)
                    
                    //TODO: localize
                    Text("Comment score")
                        .font(.footnote)
                        .foregroundColor(.foreground.opacity(0.5))
                    
                    Spacer()
                }
            }
        }
    }
}

extension FeedHamburgerView {
    var loginView: some View {
        Group {
            HStack {
                Button {
                    GraniteHaptic.light.invoke()
                    login.perform()
                } label: {
                    Image(systemName: "globe")
                        .font(.title3)
                        .foregroundColor(.foreground)
                    Text("AUTH_LOGIN")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                        .padding(.leading, .layer1)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
    
    var profileView: some View {
        Group {
            HStack {
                Group {
                    Image(systemName: "person")
                        .font(.title3)
                        .foregroundColor(.foreground)
                    //TODO: localize
                    Text("Profile")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                        .padding(.leading, .layer1)
                }
                .routeButton(window: .resizable(600, 500)) {
                    Profile(account.state.meta?.person)
                } with : { router }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
    
    var blockedListView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    GraniteHaptic.light.invoke()
                    blockedListIsActive.toggle()
                } label : {
                    Image(systemName: "exclamationmark.octagon")
                        .font(.title3)
                        .foregroundColor(.foreground)
                    Text("TITLE_BLOCKED")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            if blockedListIsActive {
                Divider()
                    .padding(.top, .layer4)
                
                BlockedPickerView(meta: account.state.meta,
                                  modal: false,
                                  verticalPadding: 0,
                                  trailingPadding: .layer4)
                    .graniteEvent(account.center.interact)
            }
        }
    }
    
    var setInstanceView: some View {
        Group {
            HStack {
                Button {
                    GraniteHaptic.light.invoke()
                    
                    ModalService.shared.presentSheet {
                        //TODO: localize
                        GraniteStandardModalView(title: "Set Instance URL", maxHeight: 210) {
                            SetInstanceView()
                                .attach({ value in
                                    config
                                        .center
                                        .restart
                                        .send(
                                            ConfigService
                                                .Restart
                                                .Meta(host: value))
                                    ModalService.shared.dismissSheet()
                                }, at: \.commit)
                        }
                    }
                } label : {
                    Image(systemName: "server.rack")
                        .font(.title3)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.foreground)
                    
                    //TODO: localize
                    Text("Set Instance")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
    
    var settingsView: some View {
        Group {
            HStack {
                Group {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.foreground)
                    
                    Text("TITLE_SETTINGS")
                        .font(.title3.bold())
                        .foregroundColor(.foreground)
                }
                .routeButton(window: .resizable(600, 500)) {
                    Settings()
                } with : { router }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
}
