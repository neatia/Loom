//
//  Reply.HeaderView.swift
//  Loom
//
//  Created by PEXAVC on 8/26/23.
//

import Foundation
import Granite
import SwiftUI
import GraniteUI
import MarkdownView

extension Reply {
    var headerView: some View {
        Group {
            switch kind {
            case .replyPost(let model):
                HeaderView(showPostActions: false)
                    .contentContext(.init(postModel: model))
            case .editReplyPost(let model, _):
                HeaderView(showPostActions: false)
                    .contentContext(.init(commentModel: model))
            case .replyComment(let model),
                    .editReplyComment(let model):
                HeaderView(showPostActions: false)
                    .contentContext(.init(commentModel: model))
            default:
                EmptyView()
            }
        }
    }
}
