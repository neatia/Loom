//
//  PostDisplayView.HeaderMenu.swift
//  Loom
//
//  Created by PEXAVC on 8/10/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

extension PostDisplayView {
    var sortMenuView: some View {
        HStack(spacing: .layer4) {
            Menu {
                ForEach(0..<sortingType.count) { index in
                    Button {
                        GraniteHaptic.light.invoke()
                        selectedSorting = index
                        pager.fetch(force: true)
                    } label: {
                        Text(sortingType[index].displayString)
                        Image(systemName: "arrow.down.right.circle")
                    }
                }
            } label: {
                Text(sortingType[selectedSorting].displayString)
                
                #if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
                #endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 80 : nil)
            
//            HostSelectorView(location: $threadLocation,
//                             model: currentModel)
//            .attach({
//                pager.reset()
//            }, at: \.fetch)
            ListingSelectorView(listingType: $listingType)
                .attach({
                    pager.reset()
                }, at: \.fetch)
            
            Spacer()
        }
        .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
        .offset(x: (Device.isExpandedLayout) ? -2 : 0, y: 0)
    }
}

extension FederatedCommentSortType {
    var displayString: LocalizedStringKey {
        switch self {
        case .top:
            return "SORT_TYPE_TOP"
        case .hot:
            return "SORT_TYPE_HOT"
        case .new:
            return "SORT_TYPE_NEW"
        case .old:
            return "SORT_TYPE_OLD"
        default:
            return .init(self.rawValue)
        }
    }
}
