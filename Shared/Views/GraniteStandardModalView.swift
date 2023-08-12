//
//  GraniteStandardView.swift
//  Loom
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation
import SwiftUI

//TODO: eventually convert all modals to this
struct GraniteStandardModalView<Header: View, Content: View>: View {
    var title: LocalizedStringKey?
    var header: (() -> Header)
    var content: (() -> Content)
    
    init(title: LocalizedStringKey? = nil,
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder content: @escaping (() -> Content)) {
        self.title = title
        self.header = header
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(iOS)
            Spacer()
            #endif
            
            ZStack {
                #if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
                #endif
                
                VStack(spacing: 0) {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            
                            if let title {
                                Text(title)
                                    .font(.title.bold())
                            } else {
                                header()
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.bottom, .layer4)
                    .padding(.leading, .layer4)
                    .padding(.trailing, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer4)
                    
                    content()
                        .padding(.horizontal, .layer4)
                }
            }
            .frame(maxHeight: 400)
            
        }
        .frame(width: Device.isMacOS ? 300 : nil)
        .padding(.top, .layer5)
        .padding(.bottom, .layer5)
    }
}
