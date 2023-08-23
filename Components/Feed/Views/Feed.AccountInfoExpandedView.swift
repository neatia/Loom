//
//  Feed.AccountInfoExpandedView.swift
//  Loom
//
//  Created by PEXAVC on 8/11/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

//TODO: organize all these views into isolated structs to maintain styling easily
extension Feed {
    var accountInfoExpandedView: some View {
        HStack {
            AccountView()
                .attach({
                    GraniteHaptic.light.invoke()
                    ModalService.shared.presentSheet {
                        LoginView()
                    }
                }, at: \.login)
                .offset(y: hasCommunityBanner ? -1 : 0)
                .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                .padding(.vertical, hasCommunityBanner ? 4 : 0)
                .backgroundIf(hasCommunityBanner) {
                    Color.background.opacity(0.75)
                        .cornerRadius(4)
                }
            Spacer()
            if Device.isExpandedLayout && state.community != nil {
                communityInfoMenuView
                    .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                    .padding(.vertical, hasCommunityBanner ? 4 : 0)
                    .backgroundIf(hasCommunityBanner) {
                        Color.background.opacity(0.75)
                            .cornerRadius(4)
                    }
            } else {
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, .layer3)
    }
}
