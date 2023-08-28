//
//  Pager.ListView.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import Combine
import SwiftUI
import Granite

extension PagerScrollView {
    var listView: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    List {
                        if properties.alternateContentPosition {
                            addContent()
                                .setupPlainListRow()
                        }
                        
                        Section(header: header()
                            .setupPlainListRow(),
                                footer: PagerFooterLoadingView<Model>().environmentObject(pager)
                            .setupPlainListRow()) {
                                
                                if !properties.alternateContentPosition {
                                    addContent()
                                        .setupPlainListRow()
                                }
                                
                                ForEach(currentItems) { item in
                                    
                                    cache(item)
                                        .padding(.vertical, properties.verticalPadding)
                                        .setupPlainListRow()
                                    
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
