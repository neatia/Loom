//
//  Pager+LoadingView.swift
//  Lemur
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
    
    var body: some View {
        
        VStack {
            if pager.fetchMoreTimedOut {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.bold())
                    .onTapGesture {
                        GraniteHaptic.light.invoke()
                        pager.tryAgain()
                    }
            } else if pager.isFetching {
                #if os(iOS)
                ProgressView()
                #else
                ProgressView()
                    .scaleEffect(0.6)
                #endif
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: hasMore ? 60 : 0, maxHeight: (hasMore ? 60 : 0))
        .onAppear {
//            if pager.enableAuxiliaryLoaders && hasMore {
//                pager.fetch()
//            }
        }
    }
}

struct PagerFooterManualLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var hasMore: Bool {
        pager.hasMore && pager.items.count >= pager.pageSize
    }
    
    var body: some View {
        
        VStack {
            Spacer()
            if pager.isFetching {
                #if os(iOS)
                ProgressView()
                #else
                ProgressView()
                    .scaleEffect(0.6)
                #endif
            } else if hasMore {
                Button {
                    GraniteHaptic.light.invoke()
                    pager.fetch()
                } label: {
                    //TODO: localize
                    Text("Load more")
                        .font(.headline.bold())
                }.buttonStyle(PlainButtonStyle())
            } else {
                EmptyView()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: hasMore ? 60 : 0, maxHeight: (hasMore ? 60 : 0))
    }
}

struct PagerLoadingView<Model: Pageable>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    var label: LocalizedStringKey
    
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
