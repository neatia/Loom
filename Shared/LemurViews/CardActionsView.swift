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
import LemmyKit

struct CardActionsView: View {
    @Environment(\.graniteEvent) var interact
    
    @Binding var enableCommunityRoute: Bool
    
    var community: Community?
    var person: Person?
    var isBlocked: Bool = false
    
    
    var body: some View {
        Menu {
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
        .addHaptic()
    }
}
