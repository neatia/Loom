//
//  AccountService.Boot.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Granite
import Foundation
import FederationKit

extension AccountService {
    struct Boot: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var accountMeta: AccountMeta?
        }
        
        @Relay var bookmark: BookmarkService
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            let accountMeta = meta?.accountMeta ?? state.meta
            guard let accountMeta else {
                LoomLog("[No account in state] \(meta?.accountMeta == nil) \(state.meta == nil)", level: .debug)
                return
            }
            
            guard let token = try? AccountService.getToken(identifier: accountMeta.username, service: accountMeta.host) else {
                
                Federation.getSite()
                state.authenticated = false
                state.meta = nil
                
                LoomLog("[No Account Found] id: \(AccountService.keychainAuthToken + accountMeta.username), service: \(AccountService.keychainService + FederationKit.host)", level: .debug)
                broadcast.send(
                    StandardNotificationMeta(title: "MISC_CONNECTED",
                                             message: "ALERT_CONNECTED_SUCCESS \(accountMeta.host)",
                                             event: .normal))
                return
            }
            
            FederationKit.setAuth(token, user: accountMeta.resource)
            
            let result = await Federation.getUserData()
            
            guard let resource = result else {
                broadcast.send(StandardNotificationMeta(title: "MISC_ERROR",
                                                        message: "MISC_ERROR_2",
                                                        event: .error))
                
                print("[AccountService] No user found")
                FederationKit.logout()
                state.meta = nil
                return
            }
            
            LoomLog("[Account Restored] - connected", level: .debug)
            
            broadcast.send(
                StandardNotificationMeta(title: "MISC_CONNECTED",
                                         message: "ALERT_CONNECTED_SUCCESS \(accountMeta.host + " @\(accountMeta.username)")",
                                         event: .success))
            
            state.meta = .init(resource: resource, host: accountMeta.host)
            state.addToProfiles = false
            state.authenticated = FederationKit.isAuthenticated()
            
            bookmark.restore(wait: true)
            bookmark.center.boot.send()
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
    
}
