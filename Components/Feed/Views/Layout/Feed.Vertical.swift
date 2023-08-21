//
//  Feed.Vertical.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

extension Feed {
    var verticalLayout: some View {
        VStack(spacing: 0) {
            FeedMainView(location: state.location,
                         communityView: state.communityView) {
                headerView
            }
             .attach({ community in
                 fetchCommunity(community, reset: true)
             }, at: \.viewCommunity)
             .attach({ postView in
                 modal.presentSheet {
                     PostContentView(postView: postView)
                         .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                 }
             }, at: \.showContent)
             .attach({ (model, metadata) in
                 DispatchQueue.main.async {
                     modal.presentSheet {
                         GraniteStandardModalView(title: "MISC_SHARE") {
                             ShareModal(urlString: model?.post.ap_id) {
                                 PostCardView()
                                     .contentContext(.init(postModel: model,
                                                           viewingContext: .screenshot))
                                     .environment(\.pagerMetadata, metadata)
                                     .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                             }
                         }
                     }
                 }
             }, at: \.share)
             .graniteEvent(account.center.interact)
             .overlay(LogoView()
                .attach({
                    modal.presentSheet {
                        Write(communityView: state.communityView)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                    }
                }, at: \.write))
             .environmentObject(pager)
        }
        .edgesIgnoringSafeArea(state.community != nil ? [.bottom] : [])
        .sideMenu(isShowing: _state.isShowing) {
            VStack(spacing: 0) {
                accountsPickerView
                if state.socialViewOptions == 0 {
                    CommunityPickerView(modal: false, verticalPadding: 0)
                        .id(config.center.state.config)
                } else {
                    BlockedPickerView(meta: account.state.meta,
                                      modal: false,
                                      verticalPadding: 0)
                    .graniteEvent(account.center.interact)
                }
            }
        }
    }
    
    var accountsPickerView: some View {
        HStack(spacing: .layer4) {
            Button {
                guard state.socialViewOptions != 0 else { return }
                GraniteHaptic.light.invoke()
                _state.socialViewOptions.wrappedValue = 0
            } label: {
                VStack {
                    Spacer()
                    Text("TITLE_COMMUNITIES")
                        .font(state.socialViewOptions == 0 ? .title.bold() : .title2.bold())
                        .opacity(state.socialViewOptions == 0 ? 1.0 : 0.6)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if account.isLoggedIn {
                Button {
                    guard state.socialViewOptions != 1 else { return }
                    GraniteHaptic.light.invoke()
                    _state.socialViewOptions.wrappedValue = 1
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_BLOCKED")
                            .font(state.socialViewOptions == 1 ? .title.bold() : .title2.bold())
                            .opacity(state.socialViewOptions == 1 ? 1.0 : 0.6)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(height: 36)
        .padding(.top, ContainerConfig.generalViewTopPadding)
        .padding(.leading, .layer4)
        .padding(.trailing, .layer4)
    }
    
}

