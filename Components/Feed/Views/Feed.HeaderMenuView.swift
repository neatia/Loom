//
//  Feed.HeaderView.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension Feed {
    var headerMenuView: some View {
        HStack(spacing: .layer4) {
            Menu {
                ForEach(0..<state.sortingType.count) { index in
                    Button {
                        GraniteHaptic.light.invoke()
                        _state.selectedSorting.wrappedValue = index
                        pager.fetch(force: true)
                    } label: {
                        Text(state.sortingType[index].displayString)
                        Image(systemName: "arrow.down.right.circle")
                    }
                }
            } label: {
                Text(state.sortingType[state.selectedSorting].displayString)
                
                #if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
                #endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 80 : nil)
            .padding(.horizontal, hasCommunityBanner ? 6 : 0)
            .padding(.vertical, hasCommunityBanner ? 4 : 0)
            .backgroundIf(hasCommunityBanner) {
                Color.background.opacity(0.75)
                    .cornerRadius(4)
            }
            
            if state.sortingType[state.selectedSorting] == .topAll {
                Menu {
                    ForEach(0..<state.sortingTimeType.count) { index in
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.selectedTimeCategory.wrappedValue = index
                            pager.fetch(force: true)
                        } label: {
                            Text(LocalizedStringKey(state.sortingTimeType[index]))
                            Image(systemName: "arrow.down.right.circle")
                        }
                    }
                } label: {
                    Text(LocalizedStringKey(state.sortingTimeType[state.selectedTimeCategory]))
                    #if os(iOS)
                    Image(systemName: "chevron.up.chevron.down")
                    #endif
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(maxWidth: Device.isMacOS ? 80 : nil)
                .padding(.horizontal, hasCommunityBanner ? 6 : 0)
                .padding(.vertical, hasCommunityBanner ? 4 : 0)
                .backgroundIf(hasCommunityBanner) {
                    Color.background.opacity(0.75)
                        .cornerRadius(4)
                }
                
                Divider()
            }
            
            if state.community == nil {
                Menu {
                    ForEach(0..<state.listingType.count) { index in
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.selectedListing.wrappedValue = index
                            pager.fetch(force: true)
                        } label: {
                            Text(state.listingType[index].displayString)
                            Image(systemName: "arrow.down.right.circle")
                        }
                    }
                } label: {
                    Text(state.listingType[state.selectedListing].displayString)
#if os(iOS)
                    Image(systemName: "chevron.up.chevron.down")
#endif
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(maxWidth: Device.isMacOS ? 100 : nil)
            }
            Spacer()
        }
        .padding(.top, hasCommunityBanner ? .layer1 : 0)
        .offset(x: (hasCommunityBanner == false && Device.isExpandedLayout) ? -2 : 0, y: 0)
    }
}
