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
                    .readability(bgColor: .secondaryBackground)
                    .outline()
                    .padding(.layer4)
            } else {
                EmptyView()
            }
            
            ProfilePickerView(kind: _state.viewingDataType, isMe: state.person?.isMe == true)
                .attach( {
                    pager.clear()
                    pager.fetch(force: true)
                }, at: \.refresh)
        }
        .background(Color.background)
    }
}
