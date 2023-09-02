//
//  Pager+LoadingView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Combine

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
    
    //ideally the same height as the tab bar
    var height: CGFloat {
        if Device.hasNotch {
            return 75
        } else {
            return 60
        }
    }
    
    var body: some View {
        
        VStack {
            if pager.isFetching && !pager.fetchMoreTimedOut {
                StandardProgressView()
            } else {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.bold())
                    .onTapGesture {
                        GraniteHaptic.light.invoke()
                        pager.tryAgain()
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
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
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                if pager.isFetching || pager.initialFetch {
                    StandardProgressView()
                } else {
                    VStack(spacing: .layer3) {
                        Text(label)
                            .font(.headline.bold())
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            pager.reset()
                        } label : {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.headline.bold())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, .layer3)
            
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
