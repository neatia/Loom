//
//  Config.Restart.swift
//  Loom
//
//  Created by PEXAVC on 8/15/23.
//

import Foundation
import SwiftUI
import Granite
import LemmyKit

extension ConfigService {
    struct Restart: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            var accountMeta: AccountMeta?
            var host: String?
        }
        
        @Payload var meta: Meta?
        
        @Relay var account: AccountService
        @Relay var content: ContentService
        
        func reduce(state: inout Center.State) async {
            guard let meta else { return }
            
            if let host = meta.host {
                LemmyKit.baseUrl = host
                state.config = .init(baseUrl: host)
            } else if let accountMeta = meta.accountMeta {
                LemmyKit.baseUrl = accountMeta.host
                state.config = .init(baseUrl: accountMeta.host)
                
                account.center.boot.send(AccountService.Boot.Meta(accountMeta: accountMeta))
            }
                
            guard meta.host != nil || meta.accountMeta != nil else { return }
            
            let host: String = (meta.host ?? meta.accountMeta?.host) ?? ""
            
            content.preload()
            content.center.boot.send()
            
            if meta.accountMeta == nil {
                broadcast.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(host)", event: .normal))
            } else {
                //This will notify Feed's receivers to reset the content
                //But will avoid stacking toasts on Globe's receiver
                broadcast.send(nil)
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
