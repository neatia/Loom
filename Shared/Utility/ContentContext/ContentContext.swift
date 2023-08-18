//
//  Context.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/18/23.
//

import Foundation
import SwiftUI
import LemmyKit

struct ContentContextKey: EnvironmentKey {
    static var defaultValue: ContentContext = .init()
}

extension EnvironmentValues {
    var context: ContentContext {
        get { self[ContentContextKey.self] }
        set { self[ContentContextKey.self] = newValue }
    }
}

struct ContentContext {
    var postModel: PostView?
    var commentModel: CommentView?
    var style: FeedStyle = .style2
    var viewingContent: ViewingContext = .base
}
