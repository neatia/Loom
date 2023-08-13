//
//  Pager+LoadingView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Combine
import LemmyKit
import SwiftUI
import Granite
import GraniteUI


struct PagerFooterLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var hasMore: Bool {
        pager.hasMore && pager.items.count >= pager.pageSize
    }
    
    
    func progressWidth(_ proxy: GeometryProxy) -> CGFloat {
        let width = proxy.size.width * pager.rlProcessingProgress
        
        return width.isFinite ? width : 0
    }
    
    var body: some View {
        
        VStack {
            if pager.isFetching && !pager.fetchMoreTimedOut {
                #if os(iOS)
                ProgressView()
                #else
                ProgressView()
                    .scaleEffect(0.6)
                #endif
            } else {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.bold())
                    .onTapGesture {
                        GraniteHaptic.light.invoke()
                        pager.tryAgain()
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: hasMore ? 60 : 0, maxHeight: (hasMore ? 60 : 0))
        .background(
            ZStack(alignment: .top) {
                GeometryReader { proxy in
                    Brand.Colors.yellow.opacity(0.8)
                        .frame(width: progressWidth(proxy), height: .infinity)
                        .animation(.easeIn, value: pager.rlProcessingProgress)
                    
                }
                
                Divider()
            }
            , alignment: .bottomLeading)
    }
}

struct PagerLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var label: LocalizedStringKey
    
    func progressWidth(_ proxy: GeometryProxy) -> CGFloat {
        let width = proxy.size.width * pager.rlProcessingProgress
        
        return width.isFinite ? width : 0
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if pager.isFetching {
                    #if os(iOS)
                    ProgressView()
                    #else
                    ProgressView()
                        .scaleEffect(0.6)
                    #endif
                } else {
                    Text(label)
                        .font(.headline.bold())
                }
                Spacer()
            }
            
            Spacer()
        }
        .background(
            GeometryReader { proxy in
                Brand.Colors.yellow.opacity(0.8)
                    .frame(width: progressWidth(proxy), height: .infinity)
                    .animation(.easeIn, value: pager.rlProcessingProgress)
                
            }
            , alignment: .bottomLeading)
    }
}

extension View {
    func setupPlainListRow() -> some View {
        if #available(macOS 13.0, *) {
            return self
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                     .listRowSeparator(.hidden)
                     .background(Color.clear.onTapGesture { })
        } else {
            return self
        }
    }
}
