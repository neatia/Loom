//
//  GraniteSheetView.swift
//  Loom
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

/*
 TODO: Remove in favor of GraniteStandardModalView?
 
 */

struct GraniteSheetView<Content: View>: View {
    var title: LocalizedStringKey?
    let height: CGFloat
    var content: (() -> Content)
    
    init(title: LocalizedStringKey? = nil,
         height: CGFloat? = nil,
         @ViewBuilder view: @escaping (() -> Content)) {
        self.title = title
        self.height = height ?? 400
        self.content = view
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
#if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.background)
                    .edgesIgnoringSafeArea(.all)
#endif
                VStack(spacing: 0) {
                    if let title {
                        HStack(spacing: .layer4) {
                            VStack {
                                Spacer()
                                Text(title)
                                    .font(.title.bold())
                            }
                            
                            Spacer()
                        }
                        .frame(height: 36)
                        .padding(.bottom, .layer4)
                        .padding(.horizontal, .layer5)
                        
                        Divider()
                            .padding(.bottom, .layer4)
                    }
                    
                    content()
                        .padding(.horizontal, .layer5)
                    
                    Spacer()
                }
                .padding(.top, Device.isMacOS ? 0 : .layer5)
                .padding(.bottom, .layer5)
            }
            .frame(maxHeight: height)
        }
        .padding(.top, Device.isMacOS ? .layer4 : .layer5)
        .padding(.bottom, Device.isMacOS ? .layer4 : .layer5)
    }
}

struct GraniteSheetCustomTitleView<TitleContent: View, Content: View>: View {
    var title: LocalizedStringKey?
    let height: CGFloat
    var titleContent: (() -> TitleContent)
    var content: (() -> Content)
    
    init(title: LocalizedStringKey? = nil,
         height: CGFloat? = nil,
         @ViewBuilder titleView: @escaping (() -> TitleContent),
         @ViewBuilder view: @escaping (() -> Content)) {
        self.title = title
        self.height = height ?? 400
        self.titleContent = titleView
        self.content = view
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
#if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.background)
                    .edgesIgnoringSafeArea(.all)
#endif
                VStack(spacing: 0) {
                    titleContent()
                    .padding(.bottom, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer4)
                    
                    content()
                    
                    Spacer()
                }
                .padding(.layer5)
            }
            .frame(maxHeight: height)
        }
        .frame(width: Device.isMacOS ? 400 : nil, height: Device.isMacOS ? 600 : nil)
    }
}
