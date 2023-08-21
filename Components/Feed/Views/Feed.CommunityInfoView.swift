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
import LemmyKit

extension Feed {
    var communityInfoView: some View {
        HStack {
            Spacer()
            
            communityInfoMenuView
        }.frame(maxWidth: .infinity)
    }
    
    var communityInfoMenuView: some View {
        Menu {
            if state.location == .base {
                if let communityView = state.communityView {
                    Button {
                        guard communityView.subscribed != .pending else { return }
                        GraniteHaptic.light.invoke()
                        if account.isLoggedIn {
                            account.center.interact.send(AccountService.Interact.Meta(intent: .subscribe(communityView)))
                        } else {
                            ModalService.shared.presentSheet {
                                LoginView()
                            }
                        }
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
                }
                
                Divider()
            }
            
            if state.location != .base {
                Button {
                    _state.location.wrappedValue = .base
                    pager.reset()
                } label: {
                    Text("LISTING_TYPE_LOCAL")
                    Image(systemName: "house")
                }
                .buttonStyle(PlainButtonStyle())
                
                if state.peerLocation == nil {
                    Divider()
                }
            }
            
            if (state.location == .base && LemmyKit.host != state.community?.ap_id?.host) || (state.location.isPeer) {
                Button {
                    _state.location.wrappedValue = .source
                    pager.reset()
                } label: {
                    //TODO: localize
                    Text("@\(state.community?.actor_id.host ?? "Source")")
                    Image(systemName: "globe.americas")
                }
                .buttonStyle(PlainButtonStyle())
                
                if state.location.isPeer || state.peerLocation == nil {
                    Divider()
                }
            }
            
            if state.location.isPeer == false,
               case .peer(let host) = state.peerLocation {
                Button {
                    guard let location = state.peerLocation else { return }
                    _state.location.wrappedValue = location
                    pager.reset()
                } label: {
                    Text("@\(host)")
                    Image(systemName: "person.2.wave.2")
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
            
            
            Button {
                guard let communityView = state.communityView else { return }
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
                guard let communityView = state.communityView else { return }
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
                .font(Device.isExpandedLayout ? .title : .title3)
                .contentShape(Rectangle())
                .foregroundColor(.foreground)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .frame(width: 20)
//            .scaleEffect(x: -1, y: 1)
        .addHaptic()
    }
}
