//
//  GenericPreview.swift
//  Loom
//
//  Created by PEXAVC on 8/22/23.
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
    
    enum FontSize {
        case large
        case medium
        case small
    }
    
    @State var currentFontSize: FontSize = .small
    
    var currentFontGroup: PostDisplayFontGroup {
        switch currentFontSize {
        case .large:
            return .init(.title)
        case .medium:
            return .init(.title3)
        case .small:
            return .init()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: .layer2) {
                    HStack(alignment: .bottom, spacing: .layer2) {
                        Button {
                            GraniteHaptic.light.invoke()
                            currentFontSize = .large
                        } label: {
                            Image(systemName: "textformat")
                                .font(.title)
                                .frame(width: 32, height: 32)
                                .readability(padding: 0)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.layer1)
                        .outlineIf(currentFontSize == .large)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            currentFontSize = .medium
                        } label: {
                            Image(systemName: "textformat")
                                .font(.title3)
                                .frame(width: 32, height: 32)
                                .readability(padding: 0)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.layer1)
                        .outlineIf(currentFontSize == .medium)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            currentFontSize = .small
                        } label: {
                            Image(systemName: "textformat")
                                .font(.subheadline)
                                .frame(width: 32, height: 32)
                                .readability(padding: 0)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.layer1)
                        .outlineIf(currentFontSize == .small)
                    }
                    .padding(.layer2)
                    .outline()
                    
                    Spacer()
                }
                .padding(.top, Device.isMacOS ? nil : .layer4)
                .padding(.bottom, Device.isMacOS ? nil : .layer4)
                .padding(.horizontal, .layer4)
                
                ScrollView {
                    MarkdownView(text: content)
                        .markdownViewRole(.editor)
                        .fontGroup(currentFontGroup)
                        .padding(.top, Device.isMacOS ? nil : .layer4)
                        .padding(.bottom, Device.isMacOS ? nil : .layer5)
                        .padding(.horizontal, .layer2)
                }
                .padding(.horizontal, .layer3)
            }
        }
        //.padding(.top, ContainerConfig.generalViewTopPadding)
        .frame(width: Device.isMacOS ? 400 : nil)
        .frame(minHeight: Device.isMacOS ? 400 : nil)
        .background(Device.isIPhone ? Color.alternateSecondaryBackground : Color.background)
    }
}
