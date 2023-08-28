//
//  Pager.ScrollView.Simple.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

/*
 macOS has its own issues, atleast Intel, when
 wanting to achieve very smooth scrolling.
 
 current strategy is using NSScrollView + NSStackViews,
 this requires pager to hold currentItems objects that are
 only in chunks of the response and not the entire list
 as each view update will insert the chunk, not refresh the
 entire view with an entirely new list
 
 requires a bit more manual management during reset + clear + clean
 logics
 
 definitely requires a bit more revision for consistencies related to
 passed in models and their states.
 
 */
extension PagerScrollView {
    var simpleScrollView: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            if !properties.alternateContentPosition {
                addContent()
            }
            NSScrollViewWrapper($pager.shouldUpdate) {
                LazyVStack(spacing: 0) {
                    //Generates a section in a stackView
                    ForEach(pager.currentLastItems) { item in
                        mainContent(item)
                            .environment(\.pagerMetadata,
                                          pager.itemMetadatas[item.id])
                    }
                }
            }
            .id(pager.shouldReset)
            if properties.showFetchMore {
                PagerFooterLoadingView<Model>()
                    .environmentObject(pager)
            }
        }
        #else
        GraniteScrollView(showsIndicators: false,
                          onRefresh: pager.refresh(_:)) {
            if !properties.alternateContentPosition {
                addContent()
            }

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
        #endif
    }
}
