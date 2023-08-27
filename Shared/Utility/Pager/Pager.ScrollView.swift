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
    
    struct Properties {
        var alternateContentPosition: Bool = false
        var hideDivider: Bool = false
        var hideLastDivider: Bool = false
        var performant: Bool = false
        var lazy: Bool = true
        var cacheViews: Bool = false
        var showFetchMore: Bool = true
        var verticalPadding: CGFloat = 0
        var backgroundColor: Color = .clear
    }
    
    @EnvironmentObject private var pager: Pager<Model>
    
    var currentItems: [Model] {
        pager.currentItems
    }
    
    let cache: LazyScrollViewCache<AnyView> = .init()
    
    let header: () -> Header
    let addContent: () -> AddContent
    let content: (Model) -> Content
    
    let properties: Properties
    
    //TODO: create style struct for these extra props
    init(_ model: Model.Type,
         properties: Properties = .init(),
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder inlineBody: @escaping (() -> AddContent) = { EmptyView() },
         @ViewBuilder content: @escaping (Model) -> Content) {
        self.header = header
        self.addContent = inlineBody
        self.content = content
        self.properties = properties
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if pager.isEmpty {
                if properties.alternateContentPosition {
                    addContent()
                        .padding(.top, 0)
                }
                header()
                VStack(spacing: 0) {
                    if !properties.alternateContentPosition {
                        addContent()
                    }
                    PagerLoadingView<Model>(label: pager.emptyText)
                        .environmentObject(pager)
                        .frame(maxHeight: .infinity)
                }
            } else {
                if properties.performant {
                    if Device.isExpandedLayout == false {
                        header()
                    }
                    simpleScrollView
                } else {
                    normalScrollView
                }
            }
        }
    }
    
    var normalScrollView: some View {
        GraniteScrollView(onRefresh: pager.refresh(_:),
                          bgColor: properties.backgroundColor) {

            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {

                if properties.alternateContentPosition {
                    addContent()
                }

                Section(header: header()) {
                    if !properties.alternateContentPosition {
                        addContent()
                    }

                    ForEach(currentItems) { item in
                        mainContent(item)
                            .environment(\.pagerMetadata, pager.itemMetadatas[item.id])
                    }
                }
                
                if properties.showFetchMore {
                    PagerFooterLoadingView<Model>()
                        .environmentObject(pager)
                }
            }.padding(.top, 1)
        }
    }
    
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
    
    func cache(_ item: Model, retrieveOnly: Bool = false, storeOnly: Bool = false) -> some View {
        if storeOnly == false,
           let view = cache.viewCache[item.id] {
            
            return view
        }
        
        if retrieveOnly {
            return AnyView(EmptyView())
        }
        
        let view: AnyView = AnyView(mainContent(item))
        
        if properties.cacheViews {
            cache.viewCache[item.id] = view
            cache.flush()
        }
        
        if storeOnly {
            return AnyView(EmptyView())
        } else {
            return view
        }
    }
    
    func mainContent(_ item: Model) -> some View {
        VStack(spacing: 0) {
            content(item)
                .padding(.vertical, properties.verticalPadding)
            
            if !properties.hideDivider {
                if !properties.hideLastDivider || item.id != pager.lastItem?.id {
                    Divider()
                }
            }
        }
        .background(properties.backgroundColor)
    }
}
