//
//  Feed.TitleBarView.swift
//  Lemur (iOS)
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
                AvatarView(state.person?.avatarURL, size: .medium)
                    .padding(.trailing, .layer3)
                VStack(alignment: .leading, spacing: 0) {
                    Text(subheaderTitle)
                        .font(.footnote)
                    Text(headerTitle)
                        .font(.title.bold())
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
                            .route(title: "", style: .init(size: .init(width: 400, height: 500))) {
                                ProfileSettingsView(isModal: true, modal: modal)
                            }
                        
                        Spacer()
                    }
                }
                //             .routeIf(Device.isMacOS,
                //                      style: .init(size: .init(600, 500), styleMask: .resizable)) {
                //                 Search(state.community)
                //             }
                
            }
            .frame(height: 48)
            .padding(.vertical, .layer2)
            .padding(.horizontal, .layer4)
            
            Divider()
        }
        .background(Color.background.overlayIf(state.person?.banner != nil) {
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
