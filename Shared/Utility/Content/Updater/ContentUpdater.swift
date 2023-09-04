//
//  ContentUpdater.swift
//  Loom
//
//  Created by PEXAVC on 8/23/23.
//

import Foundation
import SwiftUI
import FederationKit
import Nuke

struct ContentUpdater {
    static func clearCache() {
        Nuke.ImageCache.shared.removeAll()
        URLSession.shared.invalidateAndCancel()
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
    }
}

extension ContentUpdater {
    @MainActor
    static func fetchFederatedPostResource(_ model: FederatedPost?,
                              commentModel: FederatedComment? = nil) async -> FederatedPostResource? {
        guard let postView = await Federation.post(model,
                                                   comment: commentModel) else {
            return nil
        }
        
        return postView
    }
}

//MARK: removal

extension ContentUpdater {
    
    @MainActor
    static func deletePost(_ model: FederatedPostResource?) async -> FederatedPostResource? {
        guard let model else { return nil }
        let response = await Federation.deletePost(model.post, deleted: model.post.deleted)
        
        if response?.post.deleted == true {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               //TODO: localize
                                               message: "Post deleted",
                                               event: .success))
        } else if response != nil {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               message: "ALERT_POST_RESTORED_SUCCESS",
                                               event: .success))
        }
        
        return response
    }
    
    @MainActor
    static func deleteComment(_ model: FederatedCommentResource?) async -> FederatedCommentResource? {
        guard let model else { return nil }
        let response = await Federation.deleteComment(model.comment,
                                                 deleted: model.comment.deleted)
        
        if response?.comment.deleted == true {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               //TODO: localize
                                               message: "Post deleted",
                                               event: .success))
        } else if response != nil {
            ModalService
                .shared
                .presentModal(GraniteToastView(title: "MISC_SUCCESS",
                                               message: "ALERT_POST_RESTORED_SUCCESS",
                                               event: .success))
        }
        
        return response
    }
}
