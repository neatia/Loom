//
//  Feed.HeaderMenuView.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension Search {
    var headerMenuView: some View {
        HStack(spacing: 0) {
            Text("Sort: ")
                .padding(.trailing, .layer2)
            
            Menu {
                ForEach(0..<state.sortingType.count) { index in
                    Button {
                        GraniteHaptic.light.invoke()
                        _state.selectedSorting.wrappedValue = index
                    } label: {
                        Text(state.sortingType[index].displayString)
                        Image(systemName: "arrow.down.right.circle")
                    }
                }
            } label: {
                Text(selectedSort.displayString)
                #if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
                #endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 100 : nil)
            .padding(.trailing, state.sortingType[state.selectedSorting] == .topAll ? .layer4 : 0)
            .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
            //Menus have odd interactions on iOS, effectively cancelling animations
            .id(selectedSort)
            
            
            if state.sortingType[state.selectedSorting] == .topAll {
                Menu {
                    ForEach(0..<state.sortingTimeType.count) { index in
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.selectedTimeCategory.wrappedValue = index
                            //pager.fetch(force: true)
                        } label: {
                            Text(state.sortingTimeType[index])
                            Image(systemName: "arrow.down.right.circle")
                        }
                    }
                } label: {
                    Text(state.sortingTimeType[state.selectedTimeCategory])
                    #if os(iOS)
                    Image(systemName: "chevron.up.chevron.down")
                    #endif
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(maxWidth: Device.isMacOS ? 80 : nil)
                .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
                //Menus have odd interactions on iOS, effectively cancelling animations
                .id(selectedSort.rawValue + "\(state.selectedTimeCategory)")
            }
            
            Divider()
                .padding(.horizontal, .layer4)
            
            Menu {
                ForEach(0..<state.listingType.count) { index in
                    Button {
                        GraniteHaptic.light.invoke()
                        _state.selectedListing.wrappedValue = index
                        //pager.fetch(force: true)
                    } label: {
                        Text(state.listingType[index].displayString)
                        Image(systemName: state.listingType[index].systemImageName)
                    }
                }
            } label: {
                Text(selectedListing.displayString)
#if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
#endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 80 : nil)
            .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
            //Menus have odd interactions on iOS, effectively cancelling animations
            .id(selectedSort.rawValue + "\(state.selectedTimeCategory)" + selectedListing.rawValue)
            
            Spacer()
        }
        .offset(x: Device.isMacOS ? -2 : 0, y: 0)
        .cancelAnimations()
    }
}
