//
//  GenericPreview.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/22/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import Combine
import MarkdownView

struct GenericPreview: View {
    @Environment(\.presentationMode) var presentationMode
    
    var content: String
    
    var isModal: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        //TODO: localize
                        Text("Preview")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                    
                    if isModal {
                        VStack {
                            Spacer()
                            
                            Button {
                                GraniteHaptic.light.invoke()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: Device.isMacOS ? "xmark" : "chevron.down")
                                    .renderingMode(.template)
                                    .font(.title2)
                                    .frame(width: 24, height: 24)
                                    .contentShape(Rectangle())
                                    .foregroundColor(.foreground)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 2)
                        }
                    }
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.horizontal, .layer5)
                .padding(.top, Device.isExpandedLayout == false ? .layer5 : 0)
                
                Divider()
                
                ScrollView {
                    MarkdownView(text: content)
                        .markdownViewRole(.editor)
                        .fontGroup(PostDisplayFontGroup())
                        .padding(.top, .layer4)
                        .padding(.top, Device.isMacOS ? nil : .layer4)
                        .padding(.bottom, Device.isMacOS ? nil : .layer5)
                        .padding(.horizontal, .layer2)
                }
                .padding(.horizontal, .layer3)
            }
        }
        .padding(.top, ContainerConfig.generalViewTopPadding)
        .frame(width: Device.isMacOS ? 400 : nil)
        .background(Color.background)
    }
}
