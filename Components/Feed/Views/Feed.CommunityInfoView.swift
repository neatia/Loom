//
//  Feed.CommunityInfoView.swift
//  Lemur (iOS)
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import GraniteUI
import Granite
import SwiftUI

extension Feed {
    var communityInfoView: some View {
        HStack {
            
            Spacer()
            
            Menu {
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
