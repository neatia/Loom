//
//  Interact.swift
//  Lemur
//
//  Created by PEXAVC on 7/20/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension AccountService {
    struct AddProfile: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var username: String
            var password: String
            var token2FA: String
            var host: String
        }
        
        @Event var response: AddProfileResponse.Reducer
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            
            guard let meta else { return }

            let client = Lemmy(apiUrl: meta.host)
            let username = meta.username
            let password = meta.password
            let token2fa = meta.token2FA
            _ = Task {
                let token = await client.login(username: username,
                                                  password: password,
                                                  token2FA: token2fa)

                guard let data = token?.data(using: .utf8),
                      let info = client.user else {
                    broadcast.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                    return
                }

                do {
                    try AccountService.insertToken(data, identifier: AccountService.keychainAuthToken + meta.username, service: AccountService.keychainService + meta.host)
                    
                    broadcast.send(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_ADD_ACCOUNT_SUCCESS \(meta.username)", event: .success))
                    
                    response.send(AddProfileResponse.Meta(info: info, host: meta.host))
                } catch let error {
                    
                    #if DEBUG
                    broadcast.send(StandardErrorMeta(title: "MISC_ERROR", message: "Could not save into keychain", event: .error))
                    #endif
                    
                    LoomLog("keychain: \(error)", level: .error)
                }
            }
        }
    }
    
    struct AddProfileResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var info: MyUserInfo
            var host: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
            state.profiles.append(.init(info: meta.info, host: meta.host))
            
        }
    }
}
