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
        let width = proxy.size.width * progress
        
        return width.isNaN == false && width.isFinite && width >= 0 ? width : 0
    }
    
    @State var progress: CGFloat = 0.0
    
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
        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
        .overlay(
            GeometryReader { proxy in
                ZStack {
                    Color.background
                    Color.random.opacity(0.7)
                }
                .frame(width: progressWidth(proxy))
                .animation(.easeIn, value: progress)
            }
            , alignment: .bottomLeading)
        .task {
            pager.progress { value in
                self.progress = value ?? 0.0
            }
        }
    }
}

struct PagerLoadingView<Model: Pageable>: View {
    
    @EnvironmentObject private var pager: Pager<Model>
    
    var label: LocalizedStringKey
    
    @MainActor
    func progressWidth(_ proxy: GeometryProxy) -> CGFloat {
        let width = proxy.size.width * progress
        
        return width.isNaN == false && width.isFinite && width >= 0 ? width : 0
    }
    
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if pager.isFetching || pager.hasMore {
                    #if os(iOS)
                    ProgressView()
                    #else
                    ProgressView()
                        .scaleEffect(0.6)
                    #endif
                } else if pager.hasMore == false {
                    Text(label)
                        .font(.headline.bold())
                }
                Spacer()
            }
            
            Spacer()
        }
        .overlay(
            GeometryReader { proxy in
                ZStack {
                    Color.background
                    Color.random.opacity(0.7)
                }
                .frame(width: progressWidth(proxy))
                .animation(.easeIn, value: progress)
            }
            , alignment: .bottomLeading)
        .task {
            pager.progress { value in
                self.progress = value ?? 0.0
            }
        }
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
