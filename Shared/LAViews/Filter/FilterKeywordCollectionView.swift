//
//  FilterCollectionView.swift
//  Loom
//
//  Created by PEXAVC on 9/1/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct FilterKeywordCollectionView: View {
    @GraniteAction<FilterConfig.Keyword?> var addKeyword
    
    var config: FilterConfig
    
    var body: some View {
        ScrollView([.horizontal], showsIndicators: false) {
            HStack(spacing: .layer4) {
                Button {
                    GraniteHaptic.light.invoke()
                    addKeyword.perform(nil)
                } label: {
                    Image(systemName: "plus")
                        .font(.footnote.bold())
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .aspectRatio(1.0, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(Color.alternateBackground.opacity(0.7))
                )
                .padding(.layer1)
                .outline(cornerRadius: 6)
                
                ForEach(config.keywords) { keyword in
                    Button {
                        GraniteHaptic.light.invoke()
                        addKeyword.perform(keyword)
                    } label: {
                        Text(keyword.value)
                            .font(.headline)
                        Image(systemName: "pencil")
                            .font(.headline)
                    }
                    .frame(height: 24)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(Color.alternateBackground.opacity(0.7))
                    )
                    .padding(.vertical, .layer1)
                    .padding(.horizontal, .layer2)
                    .outline(cornerRadius: 6)
                }
            }
        }
    }
}
