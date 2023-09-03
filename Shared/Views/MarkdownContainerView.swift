//
//  MarkdownContainerView.swift
//  Loom
//
//  Created by PEXAVC on 9/1/23.
//

import SwiftUI
import Granite
import GraniteUI
import Foundation
import MarkdownView

struct MarkdownContainerView: View {
    
    let text: String?
    var isPreview: Bool = false
    let kind: MarkdownContainerView.Kind
    
    enum Kind {
        case postDisplay
        case comment
    }
    
    /*
     Markdown does not render right away. This is causing
     view hierarchy issues and memory access bugs to environment
     values in complicated views, ie comment cards
     
     */
    var body: some View {
        Group {
            switch kind {
            case .comment:
                if isPreview {
                    ScrollView(showsIndicators: false) {
                        MarkdownView(text: text ?? "")
                            .fontGroup(CommentFontGroup())
                            .markdownViewRole(.editor)
                    }
                    .frame(height: 120)
                    .padding(.bottom, .layer3)
                } else {
                    MarkdownView(text: text ?? "")
                        .fontGroup(CommentFontGroup())
                        .markdownViewRole(.editor)
                        .padding(.bottom, .layer3)

                }
            case .postDisplay:
                ScrollView {
                    MarkdownView(text: text ?? "")
                        .markdownViewRole(.editor)
                        .fontGroup(PostDisplayFontGroup())
                        .padding(.bottom, .layer2)
                }
            }
        }
    }
}
