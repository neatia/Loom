//
//  Profile.InlineView.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import MarkdownView

extension Profile {
    var inlineView: some View {
        VStack(spacing: 0) {
            if let bio = state.person?.bio, bio.isEmpty == false {
                MarkdownView(text: bio)
                    .markdownViewRole(.editor)
                    .padding(.layer3)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(8)
                    .padding(.layer3)
            } else {
                EmptyView()
            }
            
            ProfilePickerView(kind: _state.viewingDataType)
                .attach( {
                    pager.clear()
                    pager.fetch(force: true)
                }, at: \.refresh)
        }
        .background(Color.background)
    }
}
