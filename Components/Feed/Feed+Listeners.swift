//
//  Feed+Listeners.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import Granite

import SwiftUI

extension Feed {
    var feedId: String {
        if let id = state.community?.id {
            return "feed-\(id)"
        } else {
            return "feed"
        }
    }
    
    var listeners: Void {
        //TODO: for mac, when a new window spawns, may want to set this again
        if Device.isMacOS || isCommunity == false {
            broadcastListeners
        }
        beamListeners
    }
    
    var broadcastListeners: Void {
        account
            .center
            .auth
            .listen(.broadcast(feedId)) { value in
                if let response = value as? StandardNotificationMeta {
                    ModalService.shared.presentModal(GraniteToastView(response))
                }
            }
        
        account
            .center
            .interact
            .listen(.broadcast(feedId)) { value in
                if let response = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(response))
                } else if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .blockPersonFromPost(let model):
                        pager.block(item: model)
                    case .blockPerson(let model):
                        pager.updateBlockFromPerson(item: model)
                    case .deletePost(let model):
                        pager.update(item: model)
                    default:
                        break
                    }
                    
                    ModalService.shared.presentModal(GraniteToastView(response.notification))
                }
            }
        
        config
            .center
            .restart
            .listen(.broadcast(feedId)) { value in
                if let error = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(error))
                } else {
                    LoomLog("🟡 Restarting Feed")
                    
                    ContentUpdater.clearCache()
                    
                    _state.community.wrappedValue = nil
                    _state.communityView.wrappedValue = nil
                    _state.currentLoomManifest.wrappedValue = nil
                    loom._state.activeManifest.wrappedValue = nil
                    pager.reset()
                }
            }
        
        content
            .center
            .interact
            .listen(.broadcast(feedId)) { value in
                if let meta = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(meta))
                } else if let meta = value as? ContentService.Interact.Meta {
                    switch meta.kind {
                    case .editComment:
                        //Delay for toast modals activating the keyborad prematurely
                        //TODO: localize
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ModalService.shared.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "Comment edited", event: .success)))
                        }
                    default:
                        break
                    }
                }
            }
        
        loom
            .center
            .modify
            .listen(.broadcast(feedId)) { value in
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
    
    //TODO: since relays are now single instances
    //beaming will be replaced not restored.
    var beamListeners: Void {
        account
            .center
            .interact
            .listen(.beam) { value in
                if let response = value as? StandardErrorMeta {
                    ModalService.shared.presentModal(GraniteToastView(response))
                } else if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .subscribe(let model):
                        _state.community.wrappedValue = model.community
                        _state.communityView.wrappedValue = model
                    default:
                        break
                    }
                    
                    ModalService
                        .shared
                        .presentModal(
                            GraniteToastView(response.notification)
                        )
                }
            }
    }
}
