//
//  AccountService.Details.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension AccountService {
    struct Details: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Payload var meta: Boot.Meta?
        
        func reduce(state: inout Center.State) {
            guard let user = LemmyKit.current.user else {
                print("[AccountService] No user found")
                state.meta = nil
                return
            }
            
            state.meta = .init(info: user, host: meta?.accountMeta?.host ?? LemmyKit.host)
            state.addToProfiles = false
            state.authenticated = LemmyKit.auth != nil
            
            print("[AccountService] Logged in user: \(state.meta?.username)")
        }
    }
    
    struct DetailsResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var details: GetPersonDetailsResponse?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta else {
                return
            }
        }
    }
}
