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
            
            Menu {
                if state.location == .base {
                    if let communityView = state.communityView {
                        Button {
                            guard communityView.subscribed != .pending else { return }
                            GraniteHaptic.light.invoke()
                            if account.isLoggedIn {
                                account.center.interact.send(AccountService.Interact.Meta(intent: .subscribe(communityView)))
                            } else {
                                modal.presentSheet {
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
                        pager.fetch(force: true)
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
                        pager.fetch(force: true)
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
                        pager.fetch(force: true)
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
                    modal.presentSheet {
                        CommunitySidebarView(communityView: communityView)
                    }
                } label: {
                    Text("COMMUNITY_SIDEBAR")
                    Image(systemName: "arrow.down.right.circle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(Device.isExpandedLayout ? .title : .title3)
                    .contentShape(Rectangle())
                    .foregroundColor(.foreground)
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .menuIndicator(.hidden)
            .frame(width: 24)
//            .scaleEffect(x: -1, y: 1)
            .addHaptic()
            
            
        }.frame(maxWidth: .infinity)
    }
}
