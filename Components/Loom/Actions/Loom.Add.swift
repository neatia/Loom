//
//  Loom.Add.swift
//  Loom
//
//  Created by PEXAVC on 9/3/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

extension Loom {
    func addToLoom(_ manifest: LoomManifest) {
        
        switch FederationKit.currentInstanceType {
        case .rss:
            Task.detached { @MainActor in
                guard let communityResource = await FederationKit.currentServer?.fetchServerAsCommunity() else {
                    return
                }
                //The entire instance is essentially a "community"
                //no haptic since the action to initiate triggers one
                service
                    .center
                    .modify
                    .send(
                        LoomService
                            .Modify
                            .Intent
                            .add(communityResource, manifest)
                    )
            }
        default:
            
            ModalService.shared.presentSheet {
                CommunityPickerView()
                    .attach({ (communityView, _) in
                        GraniteHaptic.light.invoke()
                        
                        service.center.modify.send(LoomService.Modify.Intent.add(communityView, manifest))
                        
                    }, at: \.pickedCommunity)
                    .frame(width: Device.isMacOS ? 400 : nil, height: Device.isMacOS ? 400 : nil)
            }
        }
    }
}
