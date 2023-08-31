//
//  CardActionsView.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct CardActionsView: View {
    @Environment(\.graniteEvent) var interact
    @Environment(\.graniteRouter) var router
    
    @Binding var enableCommunityRoute: Bool
    
    var community: FederatedCommunity?
    var person: FederatedPerson?
    var isBlocked: Bool = false
    var canRemoveFromProfiles: Bool = false
    
    
    var body: some View {
        Menu {
            personalActionsView
            if person?.isMe == false && !canRemoveFromProfiles {
                generalActionsView
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(Device.isExpandedLayout ? .subheadline : .footnote.bold())
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .foregroundColor(.foreground)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .frame(width: 24, height: 24)
        //.scaleEffect(x: -1, y: 1)
    }
}

extension CardActionsView {
    var personalActionsView: some View {
        Group {
            Button {
                GraniteHaptic.light.invoke()
                
                router.navigation.push {
                    Profile(person)
                }
            } label: {
                //TODO: localize
                Text("Profile")
                Image(systemName: "person")
            }
            .buttonStyle(PlainButtonStyle())
            
            if canRemoveFromProfiles {
                Divider()
                
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                    
                    interact?.send(AccountService.Interact.Meta(intent: .removeFromProfiles(person)))
                } label: {
                    Text("MISC_REMOVE")
                    Image(systemName: "trash")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var generalActionsView: some View {
        Group {
            if let name = community?.name {
                Button {
                    GraniteHaptic.light.invoke()
                    enableCommunityRoute = true
                } label: {
                    Text("!\(name)")
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if community != nil {
                Divider()
            }
            
            Button {
                GraniteHaptic.light.invoke()
            } label: {
                Text("MISC_SHARE")
                Image(systemName: "paperplane")
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            if let person {
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                    
                    interact?
                        .send(AccountService
                            .Interact
                            .Meta(intent: .blockPerson(person)))
                } label: {
                    Text(isBlocked ? "MISC_UNBLOCK".localized("@\(person.name)", formatted: true) : "MISC_BLOCK".localized("@\(person.name)", formatted: true))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                } label: {
                    Text("MISC_REPORT".localized("@\(person.name)", formatted: true))
                }
                .buttonStyle(PlainButtonStyle())
            } else if let community {
                Button(role: .destructive) {
                    GraniteHaptic.light.invoke()
                    
                } label: {
                    Text(isBlocked ? "MISC_UNBLOCK".localized("!\(community.name)", formatted: true) : "MISC_BLOCK".localized("!\(community.name)", formatted: true))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
