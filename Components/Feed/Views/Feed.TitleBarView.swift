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

extension Feed {
    var titleBarView: some View {
         HStack(spacing: 0) {
             VStack(alignment: .leading, spacing: hasCommunityBanner ? 2 : 0) {
                 Spacer()
                 Text(subheaderTitle)
                     .font(.footnote)
                     .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                     .padding(.vertical, hasCommunityBanner ? 2 : 0)
                     .backgroundIf(hasCommunityBanner) {
                         Color.background.opacity(0.75)
                             .cornerRadius(4)
                     }
                 Text(headerTitle)
                     .font(.title.bold())
                     .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                     .padding(.vertical, hasCommunityBanner ? 2 : 0)
                     .backgroundIf(hasCommunityBanner) {
                         Color.background.opacity(0.75)
                             .cornerRadius(4)
                     }
                     .padding(.bottom, .layer1)
             }
             .foregroundColor(.foreground)
             Spacer()
             
             Button {
                 GraniteHaptic.light.invoke()
                 modal.presentSheet(style: Device.isMacOS ? .sheet : .cover) {
                     Search(state.community)
                         .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                 }
             } label: {
                 Image(systemName: "magnifyingglass")
                     .renderingMode(.template)
                     .font(Device.isMacOS ? .title2 : .title3)
                     .frame(width: 24, height: 24)
                     .contentShape(Rectangle())
                     .foregroundColor(.foreground)
                     .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                     .padding(.vertical, hasCommunityBanner ? 4 : 0)
                     .offset(y: -1)
             }
             .backgroundIf(hasCommunityBanner) {
                 Color.background.opacity(0.75)
                     .cornerRadius(4)
             }
             .buttonStyle(PlainButtonStyle())
         }
         .frame(height: hasCommunityBanner ? 48 : 36)
         .padding(.top, (Device.isMacOS && state.community == nil) ? .layer5 : .layer3)
         .padding(.bottom, .layer2)
         .padding(.leading, .layer4)
         .padding(.trailing, .layer4)
    }
}
