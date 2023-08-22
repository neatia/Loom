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
                 ModalService.shared.presentSheet {
                     PostContentView(postView: postView)
                         .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                 }
             }, at: \.showContent)
             .graniteEvent(account.center.interact)
             .overlay(LogoView()
                .attach({
                    ModalService
                        .shared
                        .showWriteModal(state.communityView)
                }, at: \.write))
             .environmentObject(pager)
        }
        .edgesIgnoringSafeArea(state.community != nil ? [.bottom] : [])
        .sideMenu(isShowing: _state.isShowing) {
            FeedHamburgerView()
                .attach( { modalView in
                    #if os(iOS)
                    ModalService.shared.present(modalView)
                    #else
                    ModalService.shared.presentModal(modalView)
                    #endif
                }, at: \.present)
                .attach( { meta in
//                    modal.presentModal(GraniteAlertView(message: .init("ALERT_SWITCH_ACCOUNT \("@\(meta.username)@\(meta.hostDisplay)")")) {
//
//                        GraniteAlertAction(title: "MISC_NO")
//                        GraniteAlertAction(title: "MISC_YES") {
//                            config.center.restart.send(ConfigService.Restart.Meta(accountMeta: meta))
//                        }
//                    })
                    config.center.restart.send(ConfigService.Restart.Meta(accountMeta: meta))
                    
                    DispatchQueue.main.async {
                        ModalService.shared.dismissAll()
                    }
                }, at: \.switchAccount)
                .attach({
                    ModalService.shared.presentSheet(detents: [.large()]) {
                        LoginView(addToProfiles: true)
                            .attach({
                                ModalService.shared.dismissSheet()
                            }, at: \.cancel)
                            .attach({
                                ModalService.shared.dismissSheet()
                            }, at: \.add)
                    }
                }, at: \.addProfile)
                .attach({
                    GraniteHaptic.light.invoke()
                    ModalService.shared.presentSheet {
                        LoginView()
                    }
                }, at: \.login)
        }
    }
}

