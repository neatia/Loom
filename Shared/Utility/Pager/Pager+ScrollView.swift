//
//  Pager+ScrollView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import Foundation
import Combine
import SwiftUI
import Granite
import GraniteUI

struct PagerScrollView<Model: Pageable, Header: View, AddContent: View, Content: View>: View {
    @EnvironmentObject private var pager: Pager<Model>
    
    let cache: LazyScrollViewCache<AnyView> = .init()
    
    let header: () -> Header
    let addContent: () -> AddContent
    let content: (Model) -> Content
    
    let hideDivider: Bool
    let alternateAddPosition: Bool
    
    let contentBGColor: Color
    
    let verticalPadding: CGFloat
    
    let useList: Bool
    
    let useSimple: Bool
    
    let cacheEnabled: Bool
    
    //TODO: create style struct for these extra props
    init(_ model: Model.Type,
         hideDivider: Bool = false,
         alternateAddPosition: Bool = false,
         contentBGColor: Color = .clear,
         verticalPadding: CGFloat = 0,
         useList: Bool = false,
         useSimple: Bool = false,
         cacheEnabled: Bool = true,
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder inlineBody: @escaping (() -> AddContent) = { EmptyView() },
         @ViewBuilder content: @escaping (Model) -> Content) {
        self.header = header
        self.addContent = inlineBody
        self.content = content
        self.hideDivider = hideDivider
        self.alternateAddPosition = alternateAddPosition
        self.contentBGColor = contentBGColor
        self.verticalPadding = verticalPadding
        self.useList = useList
        self.useSimple = useSimple
        self.cacheEnabled = cacheEnabled
    }
    
    var body: some View {
        Group {
            if pager.isEmpty {
                if alternateAddPosition {
                    addContent()
                        .padding(.top, useList ? 20 : 0)
                }
                header()
                    .padding(.top, useList && alternateAddPosition == false ? 20 : 0)
                VStack(spacing: 0) {
                    if !alternateAddPosition {
                        addContent()
                    }
                    PagerLoadingView<Model>(label: pager.emptyText)
                        .environmentObject(pager)
                        .frame(maxHeight: .infinity)
                }
            } else {
                if useSimple {
                    if Device.isExpandedLayout == false {
                        header()
                    }
                    simpleScrollView
                } else {
                    #if os(macOS)
                    normalScrollView
                    #else
                    if useList {
                        listView
                    } else {
                        normalScrollView
                    }
                    #endif
                }
            }
        }
    }
    
    var normalScrollView: some View {
        GraniteScrollView(onRefresh: pager.refresh(_:),
                          bgColor: contentBGColor) {

            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {

                if alternateAddPosition {
                    addContent()
                }

                Section(header: header(),
                        footer: PagerFooterLoadingView<Model>().environmentObject(pager)) {

                    if !alternateAddPosition {
                        addContent()
                    }

                    ForEach(pager.currentItems) { item in
//                        VStack(spacing: 0) {
//                            cache(item)
//                                .padding(.vertical, verticalPadding)
//                                //.setupPlainListRow()
//
//                            if !hideDivider,
//                               item.id != pager.lastItem?.id {
//                                Divider()
//                                    //.setupPlainListRow()
//                            }
//                        }
//                        .background(contentBGColor)
                        cache(item)
                            .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                    }

                }
            }.padding(.top, 1)
        }
    }
    
    var simpleScrollView: some View {
        GraniteScrollView(onRefresh: pager.refresh(_:),
                          onReachedEdge: { edge in
            
            if edge == .bottom,
               pager.hasMore,
               pager.isFetching == false {
                pager.fetch()
                
            }
            
        }) {
            LazyVStack(spacing: 0) {
                ForEach(pager.currentItems) { item in
                    cache(item)
                        .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                }
            }
            
            PagerFooterLoadingView<Model>()
                .environmentObject(pager)
        }
    }
    
    var listView: some View {
        
        GeometryReader { proxy in
            GraniteScrollView(onRefresh: pager.refresh(_:)) {
                List {
                    if alternateAddPosition {
                        addContent()
                            .setupPlainListRow()
                    }
                    
                    Section(header: header()
                        .setupPlainListRow(),
                            footer: PagerFooterLoadingView<Model>().environmentObject(pager)
                        .setupPlainListRow()) {
                            
                            if !alternateAddPosition {
                                addContent()
                                    .setupPlainListRow()
                            }
                            
                            ForEach(pager.currentItems) { item in
                                
                                VStack(spacing: 0) {
                                    cache(item)
                                        .padding(.vertical, verticalPadding)
                                        .setupPlainListRow()
                                    
                                    if !hideDivider,
                                       item.id != pager.lastItem?.id {
                                        Divider()
                                            .setupPlainListRow()
                                    }
                                }
                                .background(contentBGColor)
                                
                            }
                            .setupPlainListRow()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
                .listStyle(PlainListStyle())
                .frame(height: proxy.size.height)
            }
            .frame(height: proxy.size.height)
        }
    }
    
    func cache(_ item: Model, retrieveOnly: Bool = false, storeOnly: Bool = false) -> some View {
        if storeOnly == false,
           let view = cache.viewCache[item.id] {
            
            return view
        }
        
        if retrieveOnly {
            return AnyView(EmptyView())
        }
        
//        let view: Content = content(item)
        
        let view: AnyView = AnyView(
            VStack(spacing: 0) {
                content(item)
                    .padding(.vertical, verticalPadding)
                    //.setupPlainListRow()
                
                if !hideDivider,
                   item.id != pager.lastItem?.id {
                    Divider()
                        //.setupPlainListRow()
                }
            }
            .background(contentBGColor)
        )
        
        if cacheEnabled {
            cache.viewCache[item.id] = view
            cache.flush()
        }
        
        if storeOnly {
            return AnyView(EmptyView())
        } else {
            return view
        }
    }
}
