//
//  Profile+Listeners.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import Granite
import LemmyKit
import SwiftUI

extension Profile {
    var listeners: Void {
        account
            .center
            .update
            .listen { value in
                if let response = value as? AccountService.Update.ResponseMeta {
                    DispatchQueue.main.async {
                        _state.person.wrappedValue = response.person
                        ModalService.shared.presentModal(GraniteToastView(response.notification))
                    }
                }
            }
        
        account
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .removePost(let model):
                        pager.update(item: .init(commentView: nil, postView: model, isMention: false, isReply: false))
                    case .removeComment(let model):
                        //TODO: or censor? w/ restore?
                        pager.remove(item: .init(commentView: model, postView: nil, isMention: false, isReply: false))
                    default:
                        break
                    }
                    ModalService.shared.presentModal(GraniteToastView(response.notification))
                }
            }
    }
}
