//
//  ContentInteraction.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/23/23.
//

import Foundation
import LemmyKit
import SwiftUI

/*
 This approach may slowly replace the usage of reducers
 in ContentService/AccountService when updating content
 
 
 Experimenting with bubblers (see commentcardView)
 prior to proceeding
 */
struct ContentInteraction {
    enum Kind: Equatable {
        case removePost(PostView)
        case removeComment(CommentView)
        case deletePost(PostView)
        case deleteComment(CommentView)
    }
}


extension ContentInteraction {
    func execute(_ kind: ContentInteraction) {
        
    }
}
