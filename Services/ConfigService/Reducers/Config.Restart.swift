//
//  Config.Restart.swift
//  Loom
//
//  Created by PEXAVC on 8/15/23.
//

import Foundation
import SwiftUI
import Granite
import FederationKit

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
            //TODO: Someone could still sign in with an account using these checks
            if meta.accountMeta == nil {
                //Causes local acceess prompt
                //TODO: revise location of this check, maybe on the kit level?
                guard let lowercasedHost = meta.host?.lowercased(),
                      lowercasedHost.contains("local") == false,
                      lowercasedHost.contains("127.0") == false else {
                    broadcast.send(
                        StandardErrorMeta(title: "MISC_ERROR",
                                          message: "MISC_ERROR_2",
                                          event: .error))
                    return
                }
            }
            
            let server: FederationServer?
            if let host = meta.host {
                if state.allowAutomaticFinding {
                    server = .init(host: host)
                } else {//Default to lemmy
                    server = .init(.lemmy, host: host)
                }
            } else if let accountMeta = meta.accountMeta {
                server = .init(.lemmy, host: accountMeta.host)
            } else {
                server = nil
            }
            
            guard let server else {
                broadcast.send(
                    StandardErrorMeta(title: "MISC_ERROR",
                                      message: "MISC_ERROR_2",
                                      event: .error))
                return
            }
            
            FederationKit.initialize(server)
            state.server = server
            
            //if switched via profiles/accounts
            if let accountMeta = meta.accountMeta {
                account.center.boot.send(AccountService.Boot.Meta(accountMeta: accountMeta))
            }
                
            guard meta.host != nil || meta.accountMeta != nil else { return }
            
            let host: String = (meta.host ?? meta.accountMeta?.host) ?? ""
            
            content.preload()
            content.center.boot.send()
            
            if meta.accountMeta == nil {
                broadcast.send(
                    StandardNotificationMeta(title: "MISC_CONNECTED",
                                             message: "ALERT_CONNECTED_SUCCESS \(host)",
                                             event: .normal))
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
