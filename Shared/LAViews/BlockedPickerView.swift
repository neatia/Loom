//
//  BlockedPickerView.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct BlockedPickerView: View {
    @Environment(\.graniteEvent) var interact
    
    var meta: AccountMeta?
    
    var modal: Bool = true
    var verticalPadding: CGFloat = .layer5
    var trailingPadding: CGFloat = 0
    
    var users: Pager<FederatedPersonResource> = .init(emptyText: "EMPTY_STATE_NO_USERS", showBlocked: true, isStatic: true)
    var communities: Pager<FederatedCommunityResource> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES", showBlocked: true, isStatic: true)
    
    @State var page: FederatedSearchType = .users
    
    func opacityFor(_ page: FederatedSearchType) -> CGFloat {
        return self.page == page ? 1.0 : 0.6
    }
    
    func fontFor(_ page: FederatedSearchType) -> Font {
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
                                Text("TITLE_USERS")
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
                                Text("TITLE_COMMUNITIES")
                                    .font(fontFor(.communities))
                                    .opacity(opacityFor(.communities))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.bottom, .layer4)
                    .padding(.horizontal, modal ? .layer4 : 0)
                    .foregroundColor(.foreground)
                    .padding(.trailing, trailingPadding)
                    
                    Divider()
                    
                    switch page {
                    case .users:
                        PagerScrollView(FederatedPersonResource.self) {
                            EmptyView()
                        } inlineBody: {
                            EmptyView()
                        } content: { model in
                            UserCardView(model: model,
                                         isBlocked: meta?.resource.person_blocks.filter { $0.target.equals(model.person) == true }.isNotEmpty == true,
                                         fullWidth: true,
                                         showCounts: true)
                                .graniteEvent(interact)
                                .padding(.horizontal, modal ? .layer3 : 0)
                                .padding(.vertical, .layer3)
                            
                            if model.id != users.lastItem?.id {
                                Divider()
                                    .padding(.leading, modal ? .layer3 : 0)
                            }
                        }
                        .padding(.trailing, trailingPadding)
                        .environmentObject(users)
                        .task {
                            users.clear()
                            users.add(meta?.resource.person_blocks.map { $0.target.asView() } ?? [])
                        }
                        .id(meta)
                    default:
                        PagerScrollView(FederatedCommunityResource.self) {
                            EmptyView()
                        } inlineBody: {
                            EmptyView()
                        } content: { model in
                            CommunityCardView(model: model,
                                              showCounts: false,
                                              fullWidth: true)
                            .padding(.horizontal, modal ? .layer3 : 0)
                            .padding(.vertical, .layer3)
                            
                            if model.id != communities.lastItem?.id {
                                Divider()
                                    .padding(.leading, modal ? .layer3 : 0)
                            }
                        }
                        .padding(.trailing, trailingPadding)
                        .environmentObject(communities)
                        .task {
                            communities.clear()
                            communities.add(meta?.resource.community_blocks.map { $0.community.asView(isBlocked: true) } ?? [])
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
