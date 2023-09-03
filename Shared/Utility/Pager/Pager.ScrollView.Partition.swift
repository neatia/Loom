//
//  Pager.ScrollView.Partition.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

/*
 Problem/Goals
 
 Load a feed of 400+ comments with markdownview
 - markdownview lazy loads its contents then finds its ideal height
 
 1. we don't want to fix the height and hide overflow for a proper UX
 2. lazyvstack causes jumpiness on the scroll UP due to the height shifting items down not respecting the offsets
 3. VStack is too memory/cpu intensive and will not load a 400+ comment viwe with rich text data well at all, not an option.
 4. we can't take adv of iOS17's extended scrollview apis since we'd like to support lower end devices. (15.4+)
 
 proposed solution, use partitioned VStacks with a set amount of items each that load in a lazy v stack

  LazyV {
     V {
        10 items...
     }
     V {
        10 items...
     }
 
 During testing:
  A stronger stutter is visible, BUT the scrolling up behavior is much better
 */

extension PagerScrollView {
    
    var chunks: (ordering: [String], map: [String: [Model]]) {
        //10 is partition size, should be customizable
        var ordering: [String] = []
        var map: [String: [Model]] = [:]
        pager.currentItems.chunked(into: 10)
            .forEach {
                let id = "\($0.first?.id.hashValue ?? -1)"
                ordering.append(id)
                map[id] = $0
            }
        
        return (ordering, map)
    }
    
    //only iOS supported
    //won't support sticky headers for now
    var partitionScrollView: some View {
        let partitions = chunks
        return GraniteScrollView(onRefresh: pager.refresh(_:),
                          bgColor: properties.backgroundColor) {
            if properties.alternateContentPosition {
                addContent()
            }
            header()
            if !properties.alternateContentPosition {
                addContent()
            }
            LazyVStack(spacing: 0) {
                ForEach(partitions.ordering, id: \.self) { id in
                    VStack(spacing: 0) {
                        ForEach(partitions.map[id] ?? [], id: \.id) { item in
                            mainContent(item)
                                .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                        }
                    }
                }
            }
        }
    }
}
