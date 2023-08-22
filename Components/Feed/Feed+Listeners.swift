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
                    ModalService.shared.presentModal(GraniteToastView(response))
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
                    ModalService.shared.presentModal(GraniteToastView(response.notification))
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
                    ModalService.shared.presentModal(GraniteToastView(meta))
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
