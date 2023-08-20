//
//  BlockedPickerView.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import LemmyKit
import SwiftUI
import Granite
import GraniteUI

struct BlockedPickerView: View {
    @Environment(\.graniteEvent) var interact
    
    var meta: AccountMeta?
    
    var modal: Bool = true
    var verticalPadding: CGFloat = .layer5
    
    var users: Pager<PersonView> = .init(emptyText: "EMPTY_STATE_NO_USERS", showBlocked: true, isStatic: true)
    var communities: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES", showBlocked: true, isStatic: true)
    
    @State var page: SearchType = .users
    
    func opacityFor(_ page: SearchType) -> CGFloat {
        return self.page == page ? 1.0 : 0.6
    }
    
    func fontFor(_ page: SearchType) -> Font {
        return self.page == page ? .title2.bold() : .title3.bold()
    }
    
    var body: some View {
        VStack {
            if modal {
                Spacer()
            }
            
            ZStack {
#if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
#endif
                VStack(spacing: 0) {
                    HStack(spacing: .layer4) {
                        Button {
                            GraniteHaptic.light.invoke()
                            page = .users
                        } label: {
                            VStack {
                                Spacer()
                                Text("Users")
                                    .font(fontFor(.users))
                                    .opacity(opacityFor(.users))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            page = .communities
                        } label: {
                            VStack {
                                Spacer()
                                Text("Communities")
                                    .font(fontFor(.communities))
                                    .opacity(opacityFor(.communities))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.bottom, .layer4)
                    .padding(.leading, .layer4)
                    .padding(.trailing, .layer4)
                    .foregroundColor(.foreground)
                    
                    Divider()
                    
                    switch page {
                    case .users:
                        PagerScrollView(PersonView.self) {
                            EmptyView()
                        } inlineBody: {
                            EmptyView()
                        } content: { model in
                            UserCardView(model: model,
                                         isBlocked: meta?.info.person_blocks.filter { $0.target.equals(model.person) == true }.isNotEmpty == true,
                                         fullWidth: true,
                                         showCounts: true)
                                .graniteEvent(interact)
                                .padding(.leading, .layer3)
                                .padding(.trailing, .layer3)
                                .padding(.vertical, .layer3)
                            
                            if model.id != users.lastItem?.id {
                                Divider()
                                    .padding(.leading, .layer3)
                            }
                        }
                        .environmentObject(users)
                        .task {
                            users.clear()
                            users.add(meta?.info.person_blocks.map { $0.target.asView() } ?? [])
                        }
                        .id(meta)
                    default:
                        PagerScrollView(CommunityView.self) {
                            EmptyView()
                        } inlineBody: {
                            EmptyView()
                        } content: { model in
                            CommunityCardView(model: model,
                                              showCounts: false,
                                              fullWidth: true)
                            .padding(.leading, .layer3)
                            .padding(.trailing, .layer3)
                            .padding(.vertical, .layer3)
                            
                            if model.id != communities.lastItem?.id {
                                Divider()
                                    .padding(.leading, .layer3)
                            }
                        }
                        .environmentObject(communities)
                        .task {
                            communities.clear()
                            communities.add(meta?.info.community_blocks.map { $0.community.asView(isBlocked: true) } ?? [])
                        }
                        .id(meta)
                    }
                }
                .padding(.top, Device.isMacOS == false && modal ? .layer5 : 0)
            }
            .frame(maxHeight: modal ? 400 : nil)
        }
        .padding(.top, modal ? 0 : verticalPadding)
        .padding(.bottom, modal ? 0 : verticalPadding)
    }
}
