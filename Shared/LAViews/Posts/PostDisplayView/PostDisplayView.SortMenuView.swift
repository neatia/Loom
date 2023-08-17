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
import LemmyKit

extension PostDisplayView {
    var sortMenuView: some View {
        HStack(spacing: .layer4) {
            Menu {
                ForEach(0..<sortingType.count) { index in
                    Button {
                        GraniteHaptic.light.invoke()
                        selectedSorting = index
                        comments.fetch(force: true)
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
            .addHaptic()
            
            Menu {
                ForEach(0..<viewableHosts.count) { index in
                    let isSource: Bool = index == 1 && model.isBaseResource == false
                    let isPeer: Bool = !isSource && index > 0
                    let imageName: String = isSource ? "globe.americas" : (isPeer ? "person.wave.2" : "house")
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        if isSource {
                            self.threadLocation = .source
                        } else if index > 0 {
                            if model.isPeerResource {
                                self.threadLocation = .peer(viewableHosts[index])
                            } else if viewingContext.isBookmark {
                                self.threadLocation = viewingContext.bookmarkLocation
                            }
                        } else {
                            self.threadLocation = .base
                        }
                        self.selectedHost = viewableHosts[index]
                        
                        comments.fetch(force: true)
                    } label: {
                        Text(viewableHosts[index])
                        Image(systemName: imageName)
                    }
                }
            } label: {
                Text(selectedHost)
#if os(iOS)
                Image(systemName: "chevron.up.chevron.down")
#endif
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(maxWidth: Device.isMacOS ? 100 : nil)
            .addHaptic()
            
            Spacer()
        }
        .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
        .offset(x: (Device.isExpandedLayout) ? -2 : 0, y: 0)
    }
}

extension CommentSortType {
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