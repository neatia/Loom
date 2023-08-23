//
//  ContentUpdater.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/23/23.
//

import Foundation
import LemmyKit
import SwiftUI

struct ContentUpdater {
    @MainActor
    static func fetchPostView(_ model: Post?,
                              commentModel: Comment? = nil) async -> PostView? {
        guard let postView = await Lemmy.post(model?.id,
                                              comment: commentModel) else {
            return nil
        }
        
        return postView
    }
}
