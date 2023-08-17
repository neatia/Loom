//
//  Feed+Listeners.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import Granite
import LemmyKit
import SwiftUI

extension Feed {
    var listeners: Void {
        account
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? StandardErrorMeta {
                    modal.presentModal(GraniteToastView(response))
                } else if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .blockPersonFromPost(let model):
                        pager.block(item: model)
                    case .blockPerson(let model):
                        pager.updateBlockFromPerson(item: model)
                    case .removePost(let model):
                        pager.update(item: model)
                    case .subscribe(let model):
                        _state.community.wrappedValue = model.community
                        _state.communityView.wrappedValue = model
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
                    case .reportPost(let model):
                        modal.presentSheet {
                            ReportView(kind: .post(model))
                        }
                    case .reportComment(let model):
                        modal.presentSheet {
                            ReportView(kind: .comment(model))
                        }
                    case .editPost(let model):
                        modal.presentSheet {
                            Write(postView: model)
                                .attach({ updatedModel in
                                    DispatchQueue.main.async {
                                        pager.update(item: updatedModel)
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
        
        config
            .center
            .restart
            .listen(.broadcast) { _ in
                LoomLog("🟡 Restarting")
                pager.reset()
            }
        
        content
            .center
            .interact
            .listen(.broadcast) { value in
                if let meta = value as? StandardErrorMeta {
                    modal.presentModal(GraniteToastView(meta))
                }
            }
        
        loom
            .center
            .modify
            .listen(.broadcast) { value in
                if let intent = value as? LoomService.Control {
                    switch intent {
                    case .activate(let manifest):
                        _state.currentLoomManifest.wrappedValue = manifest
                        pager.reset()
                    case .deactivate:
                        _state.currentLoomManifest.wrappedValue = nil
                        pager.reset()
                    default:
                        break
                    }
                }
            }
    }
}
