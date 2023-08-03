//
//  AccountService.Boot.swift
//  Lemur
//
//  Created by PEXAVC on 7/19/23.
//

import Granite
import Foundation
import LemmyKit

extension AccountService {
    struct Boot: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var accountMeta: AccountMeta?
        }
        
        @Payload var meta: Meta?
        
        @Event var details: AccountService.Details.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta = meta?.accountMeta ?? state.meta else {
                print("[No account in state] \(meta?.accountMeta == nil) \(state.meta == nil)")
                return
            }
            
            guard let token = try? AccountService.getToken(identifier: AccountService.keychainAuthToken + meta.username, service: AccountService.keychainService + meta.host) else {
                
                Lemmy.getSite()
                state.authenticated = false
                state.meta = nil
                
                print("[No Account Found] id: \(AccountService.keychainAuthToken + meta.username), service: \(AccountService.keychainService + LemmyKit.baseUrl)")
                beam.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(meta.host)", event: .normal))
                return
            }
            
            LemmyKit.auth = token
            
            _ = Task.detached {
                _ = await Lemmy.site()
                print("[Account Restored]")
                beam.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(meta.host + " @\(meta.username)")", event: .success))
                details.send(Meta(accountMeta: meta))
            }
        }
    }
    
}
