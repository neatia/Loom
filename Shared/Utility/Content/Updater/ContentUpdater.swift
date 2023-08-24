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

//MARK: removal

extension ContentUpdater {
    
    @MainActor
    static func deletePost(_ model: PostView?) async -> PostView? {
        guard let model else { return nil }
        let response = await Lemmy.deletePost(model.post, deleted: model.post.deleted)
        
        if response?.post_view.post.deleted == true {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               //TODO: localize
                                               message: "Post deleted",
                                               event: .success))
        } else if response?.post_view != nil {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               message: "ALERT_POST_RESTORED_SUCCESS",
                                               event: .success))
        }
        
        return response?.post_view
    }
    
    @MainActor
    static func deleteComment(_ model: CommentView?) async -> CommentView? {
        guard let model else { return nil }
        let response = await Lemmy.deleteComment(model.comment,
                                                 deleted: model.comment.deleted)
        
        if response?.comment_view.comment.deleted == true {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               //TODO: localize
                                               message: "Post deleted",
                                               event: .success))
        } else if response?.comment_view != nil {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               message: "ALERT_POST_RESTORED_SUCCESS",
                                               event: .success))
        }
        
        return response?.comment_view
    }
}
