//
//  AccountService.Boot.swift
//  Loom
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
        
        func reduce(state: inout Center.State) async {
            LoomLog("booting heard")
            guard let meta = meta?.accountMeta ?? state.meta else {
                LoomLog("[No account in state] \(meta?.accountMeta == nil) \(state.meta == nil)", level: .debug)
                return
            }
            LoomLog("booting conntinuing")
            guard let token = try? AccountService.getToken(identifier: AccountService.keychainAuthToken + meta.username, service: AccountService.keychainService + meta.host) else {
                
                Lemmy.getSite()
                state.authenticated = false
                state.meta = nil
                
                LoomLog("[No Account Found] id: \(AccountService.keychainAuthToken + meta.username), service: \(AccountService.keychainService + LemmyKit.baseUrl)", level: .debug)
                broadcast.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(meta.host)", event: .normal))
                return
            }
            
            LemmyKit.auth = token
            
            let result = await Lemmy.site()
            
            guard let result else {
                broadcast.send(StandardNotificationMeta(title: "MISC_ERROR", message: "MISC_ERROR_2", event: .error))
                return
            }
            
            LoomLog("[Account Restored]", level: .debug)
            
            guard let user = LemmyKit.current.user else {
                print("[AccountService] No user found")
                state.meta = nil
                return
            }
            LoomLog("connected")
            broadcast.send(StandardNotificationMeta(title: "MISC_CONNECTED", message: "ALERT_CONNECTED_SUCCESS \(meta.host + " @\(meta.username)")", event: .success))
            
            state.meta = .init(info: user, host: meta.host)
            state.addToProfiles = false
            state.authenticated = LemmyKit.auth != nil
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
    
}
