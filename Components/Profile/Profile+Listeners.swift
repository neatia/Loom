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
                        modal.presentModal(GraniteToastView(response.notification))
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
                    modal.presentModal(GraniteToastView(response.notification))
                }
            }
        
        account
            .center
            .interact
            .listen(.beam) { value in
                if let meta = value as? AccountService.Interact.Meta {
                    switch meta.intent {
                    case .editPost(let model):
                        modal.presentSheet {
                            Write(postView: model)
                                .attach({ updatedModel in
                                    DispatchQueue.main.async {
                                        pager.update(item: .init(commentView: nil, postView: updatedModel, isMention: false, isReply: false))
                                        self.modal.dismissSheet()
                                    }
                                }, at: \.updatedPost)
                                .frame(width: Device.isMacOS ? 700 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    default:
                        break
                    }
                }
            }
        
        content
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? ContentService.Interact.Meta {
                    
                    switch response.kind {
                    case .editCommentSubmit(let model, _):
                        DispatchQueue.main.async {
                            pager.update(item: .init(commentView: model, postView: nil, isMention: false, isReply: false))
                            modal.dismissSheet()
                        }
                    case .editComment(let commentView, let postView):
                        let replyKind: Write.Kind
                        
                        if let postView {
                            replyKind = .editReplyPost(commentView, postView)
                        } else {
                            replyKind = .editReplyComment(commentView)
                        }
                        
                        DispatchQueue.main.async {
                            modal.presentSheet {
                                Reply(kind: replyKind)
                                    .frame(width: Device.isMacOS ? 500 : nil, height: Device.isMacOS ? 400 : nil)
                            }
                        }
                    default:
                        break
                    }
                }
            }
    }
}
