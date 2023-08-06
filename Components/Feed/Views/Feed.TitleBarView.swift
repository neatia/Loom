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
        HStack(alignment: .bottom, spacing: 0) {
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
             
             VStack(alignment: .trailing, spacing: 0) {
                 Spacer()
                 if Device.isExpandedLayout {
                     AccountView()
                         .attach({
                             GraniteHaptic.light.invoke()
                             modal.presentSheet {
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
                         .padding(.bottom, .layer2)
                 }
                 Button {
                     GraniteHaptic.light.invoke()
                     modal.presentSheet(style: Device.isExpandedLayout ? .sheet : .cover) {
                         Search(state.community)
                             .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                     }
                 } label: {
                     Image(systemName: "magnifyingglass")
                         .font(.title2)
                         .foregroundColor(.foreground)
                         .padding(.horizontal, hasCommunityBanner ? 4 : 0)
                         .padding(.vertical, hasCommunityBanner ? 4 : 0)
                         .contentShape(Rectangle())
                 }
                 .backgroundIf(hasCommunityBanner) {
                     Color.background.opacity(0.75)
                         .cornerRadius(4)
                 }
                 .buttonStyle(PlainButtonStyle())
                 .padding(.bottom, .layer1)
             }.frame(maxHeight: .infinity)
         }
         .frame(height: hasCommunityBanner ? 48 : 36)
         .padding(.top, (Device.isExpandedLayout && state.community == nil) ? .layer5 : .layer3)
         .padding(.bottom, .layer2)
    }
}
