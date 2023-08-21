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
            FeedHamburgerView()
                .attach( { modalView in
                    modal.present(modalView, target: .sheet)
                }, at: \.present)
                .attach( { meta in
                    modal.presentModal(GraniteAlertView(message: .init("ALERT_SWITCH_ACCOUNT \("@\(meta.username)@\(meta.hostDisplay)")")) {
                        
                        GraniteAlertAction(title: "MISC_NO")
                        GraniteAlertAction(title: "MISC_YES") {
                            config.center.restart.send(ConfigService.Restart.Meta(accountMeta: meta))
                        }
                    })
                }, at: \.switchAccount)
                .attach({
                    modal.presentSheet(detents: [.large()]) {
                        LoginView(addToProfiles: true)
                            .attach({
                                modal.dismissSheet()
                            }, at: \.cancel)
                            .attach({
                                modal.dismissSheet()
                            }, at: \.add)
                    }
                }, at: \.addProfile)
        }
    }
}

