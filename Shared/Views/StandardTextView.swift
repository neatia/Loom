//
//  StandardTextView.swift
//  Loom
//
//  Created by PEXAVC on 8/31/23.
//

import Foundation
import SwiftUI
import Granite

struct StandardTextView: View {
    
    @Binding var text: String
    var height: CGFloat = 160
    var font: Font = .title3
    
    var body: some View {
        Group {
#if os(iOS)
                TextToolView(text: $text)
                    .padding(.horizontal, .layer3)
                    .frame(height: height)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.secondaryBackground)
                    )
#else
                
                if #available(macOS 13.0, iOS 16.0, *) {
                    TextEditor(text: $text)
                        .textFieldStyle(.plain)
                        .frame(height: height)
                        .font(.title3.bold())
                        .scrollContentBackground(.hidden)
                        .padding(.layer3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.secondaryBackground)
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                StandardToolbarView()
                            }
                        }
                } else {
                    TextEditor(text: $text)
                        .textFieldStyle(.plain)
                        .font(.title3.bold())
                        .frame(height: height)
                        .padding(.layer3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.secondaryBackground)
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                StandardToolbarView()
                            }
                        }
                }
                #endif
        }
    }
}
