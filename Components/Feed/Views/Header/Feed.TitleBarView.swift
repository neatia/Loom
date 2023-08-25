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

extension Feed {
    var titleBarView: some View {
        VStack(alignment: .leading, spacing: hasCommunityBanner ? 2 : 0) {
            Text(subheaderTitle)
                .font(.footnote)
                .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                .padding(.vertical, hasCommunityBanner ? 2 : 0)
                .shinyIf(isLoom)
                .backgroundIf(hasCommunityBanner) {
                    Color.background.opacity(0.75)
                        .cornerRadius(4)
                }
                .onTapIf(state.community == nil) {
                    GraniteHaptic.light.invoke()
                    self.setInstanceURL()
                }
            
            HStack(spacing: 0) {
                Text(headerTitle)
                    .font(.title.bold())
                    .lineLimit(2)
                    .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                    .padding(.vertical, hasCommunityBanner ? 2 : 0)
                    .backgroundIf(hasCommunityBanner) {
                        Color.background.opacity(0.75)
                            .cornerRadius(4)
                    }
                    .padding(.bottom, .layer1)
                    .onTapIf(state.community == nil) {
                        GraniteHaptic.light.invoke()
                        self.setInstanceURL()
                    }
                
                Spacer()
                
                if Device.isExpandedLayout || state.community != nil {
                    Button {
                        GraniteHaptic.light.invoke()
                        ModalService.shared.presentSheet(style: Device.isExpandedLayout ? .sheet : .cover) {
                            Search(state.community, isModal: true)
                                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.foreground)
                            .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                            .padding(.vertical, hasCommunityBanner ? 6 : 0)
                            .contentShape(Rectangle())
                    }
                    .backgroundIf(hasCommunityBanner) {
                        Color.background.opacity(0.75)
                            .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    //NITPICK: visual alignment
                    .offset(y: -2)
                }
            }
        }
        .foregroundColor(.foreground)
        .padding(.bottom, .layer2)
        .padding(.top, Device.isExpandedLayout ? nil : (state.community == nil ? ContainerConfig.generalViewTopPadding : .layer3))
    }
}
