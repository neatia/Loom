//
//  Feed.TitleBarView.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import NukeUI

extension Profile {
    var titleBarView: some View {
        VStack {
            HStack(spacing: 0) {
                AvatarView(state.person?.avatarURL, size: hasBanner ? .large : .medium)
                    .padding(.trailing, .layer3)
                VStack(alignment: .leading, spacing: 0) {
                    Text(subheaderTitle)
                        .font(.footnote)
                        .textReadabilityIf(hasBanner)
                    
                    Text(headerTitle)
                        .font(.title.bold())
                        .textReadabilityIf(hasBanner)
                        .padding(.top, hasBanner ? .layer1 : 0)
                        .padding(.bottom, .layer1)
                }
                .foregroundColor(.foreground)
                
                Spacer()
                
                
                if isMe {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "gearshape")
                            .renderingMode(.template)
                            .font(Device.isMacOS ? .title2 : .title3)
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                            .foregroundColor(.foreground)
                            .route(window: .resizable(400, 500)) {
                                ProfileSettingsView(isModal: true)
                            } with : { router }
                        
                        Spacer()
                    }
                }
                //             .routeIf(Device.isMacOS,
                //                      style: .init(size: .init(600, 500), styleMask: .resizable)) {
                //                 Search(state.community)
                //             }
                
            }
            .frame(height: hasBanner ? 72 : 48)
            .padding(.bottom, .layer3)
            .padding(.horizontal, .layer4)
            .padding(.top, hasBanner ? .layer4 : 0)
            
            Divider()
        }
        .background(Color.background.overlayIf(hasBanner) {
             if let banner = state.person?.banner,
                let url = URL(string: banner) {
                 LazyImage(url: url) { state in
                     if let image = state.image {
                         image
                             .aspectRatio(contentMode: .fill)
                             .clipped()
                             //menu + header + titlebar
                     } else {
                         Color.background
                     }
                 }.allowsHitTesting(false)
             } else {
                 EmptyView()
             }
         }
         .clipped())
    }
}
