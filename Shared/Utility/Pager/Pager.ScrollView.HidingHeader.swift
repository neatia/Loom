//
//  Pager.ScrollView.HidingHeader.swift
//  Loom
//
//  Created by PEXAVC on 8/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

extension PagerScrollView {
    //Does not take addContent
    var hidingHeaderScrollView: some View {
        GraniteScrollView(showsIndicators: false,
                          onRefresh: pager.refresh(_:),
                          onReachedEdge: { edge in
            
            switch edge {
            case .bottom:
                guard pager.canAutoFetch else { return }
                LoomLog("Pager is fetching automatically", level: .debug)
                pager.fetch()
            default:
                break
            }
        },
                          hidingHeader: properties.hidingHeader,
                          bgColor: properties.backgroundColor,
                          header: header) {
            if properties.lazy {
                LazyVStack(spacing: 0) {
                    ForEach(currentItems) { item in
                        if properties.cacheViews {
                            cache(item)
                                .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                        } else {
                            mainContent(item)
                                .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                        }
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(currentItems) { item in
                        mainContent(item)
                            .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                    }
                }
            }
            
            if properties.showFetchMore {
                PagerFooterLoadingView<Model>()
                    .environmentObject(pager)
            }
        }
    }
}
