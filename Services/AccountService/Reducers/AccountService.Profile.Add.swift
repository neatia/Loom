//
//  Interact.swift
//  Loom
//
//  Created by PEXAVC on 7/20/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

extension AccountService {
    struct AddProfile: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var username: String
            var password: String
            var token2FA: String
            var host: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            
            guard let meta else { return }

            let client = Federation(.lemmy, baseUrl: meta.host)
            let username = meta.username
            let password = meta.password
            let token2fa = meta.token2FA
            
            let token = await client.login(username: username,
                                              password: password,
                                              token2FA: token2fa)

            guard let data = token?.data(using: .utf8),
                  let user = client.user() else {
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "ALERT_LOGIN_FAILED",
                                      event: .error))
                return
            }
            
            do {
                try AccountService.insertToken(data,
                                               identifier: meta.username,
                                               service: meta.host)
                
                broadcast.send(
                    StandardNotificationMeta(title: "MISC_SUCCESS",
                                             message: "ALERT_ADD_ACCOUNT_SUCCESS \(meta.username)",
                                             event: .success))
                
                state.profiles.append(.init(user))
                //Moves the user from the instanced client into the global static
                FederationKit.addUser(user)
            } catch let error {
                
                #if DEBUG
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "Could not save into keychain",
                                      event: .error))
                #endif
                
                LoomLog("keychain: \(error)", level: .error)
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
