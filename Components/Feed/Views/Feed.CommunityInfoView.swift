//
//  Feed.CommunityInfoView.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import GraniteUI
import Granite
import SwiftUI
import FederationKit

extension Feed {
    var communityInfoMenuView: some View {
        FeedCommunityInfoMenuView(community: state.community,
                                  communityView: state.communityView,
                                  location: state.location,
                                  peerLocation: state.peerLocation)
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
        .attachAndClear({ location in
            fetchCommunity(state.community,
                           location: location,
                           reset: true)
        }, at: \.changeLocation)
    }
}

struct FeedCommunityInfoMenuView: View {
    @GraniteAction<AccountService.Interact.Intent> var interact
    @GraniteAction<FederatedLocationType> var changeLocation
    
    //@Relay var account: AccountService
    @Relay var loom: LoomService
    
    let community: FederatedCommunity?
    let communityView: FederatedCommunityResource?
    let location: FederatedLocationType
    let peerLocation: FederatedLocationType?
    
    var body: some View {
        Menu {
            if location == .base {
                if let communityView {
                    Button {
                        guard communityView.subscribed != .pending else { return }
                        GraniteHaptic.light.invoke()
                        interact.perform(.subscribe(communityView))

                    } label: {
                        switch communityView.subscribed {
                        case .subscribed:
                            Text("MISC_UNSUBSCRIBE")
                        case .pending:
                            Text("MISC_PENDING")
                            Image(systemName: "exclamationmark.triangle")
                        default:
                            Text("COMMUNITY_SUBSCRIBE")
                        }
                    }
                    
                    if communityView.subscribed == .pending {
                        Button(role: .destructive) {
                            GraniteHaptic.light.invoke()
                            interact.perform(.subscribe(communityView))

                        } label: {
                            Text("MISC_CANCEL")
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Divider()
            }
            
            if location != .base {
                Button {
                    changeLocation.perform(.base)
                } label: {
                    Text("LISTING_TYPE_LOCAL")
                    Image(systemName: "house")
                }
                .buttonStyle(PlainButtonStyle())
                
                if peerLocation == nil {
                    Divider()
                }
            }
            
            if (location == .base && FederationKit.host != communityView?.community.ap_id?.host) || (location.isPeer) {
                Button {
                    changeLocation.perform(.source)
                } label: {
                    //TODO: localize
                    Text("@\(communityView?.community.actor_id.host ?? "Source")")
                    Image(systemName: "globe.americas")
                }
                .buttonStyle(PlainButtonStyle())
                
                if location.isPeer || peerLocation == nil {
                    Divider()
                }
            }
            
            if location.isPeer == false,
               case .peer(let host) = peerLocation {
                Button {
                    guard let location = peerLocation else { return }
                    changeLocation.perform(location)
                } label: {
                    Text("@\(host)")
                    Image(systemName: "person.2.wave.2")
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
            
            
            Button {
                guard let communityView else { return }
                GraniteHaptic.light.invoke()
                ModalService.shared.presentSheet {
                    CommunitySidebarView(communityView: communityView)
                }
            } label: {
                Text("COMMUNITY_SIDEBAR")
                Image(systemName: "arrow.down.right.circle")
            }
            
            Divider()
            
            Button {
                guard let communityView else { return }
                GraniteHaptic.light.invoke()
                
                guard loom.state.manifests.isEmpty == false else {
                    //TODO: localize
                    ModalService.shared.presentModal(GraniteToastView(StandardErrorMeta(title: "MISC_ERROR", message: "You do not have any Looms to add to", event: .error)))
                    
                    return
                }
                
                ModalService.shared.presentSheet {
                    LoomCollectionsView(modalIntent: .adding(communityView))
                        .frame(width: Device.isMacOS ? 400 : nil)
                        .frame(maxHeight: Device.isMacOS ? 600 : nil)
                }
                LoomLog("🪡 Adding loom, triggering intent", level: .debug)
            } label: {
                //TODO: localize
                Text("Add to a Loom")
                Image(systemName: "rectangle.stack.badge.plus")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2)
                .frame(width: Device.isMacOS ? 16 : 24, height: 24)
                .contentShape(Rectangle())
                .foregroundColor(.foreground)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .frame(width: Device.isMacOS ? 16 : 24, height: 24)
    }
}
