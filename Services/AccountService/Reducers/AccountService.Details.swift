//
//  AccountService.Details.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

//TODO: I think details can be cleaned/removed?
extension AccountService {
    struct Details: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Payload var meta: Boot.Meta?
        
        func reduce(state: inout Center.State) {
            guard let user = FederationKit.user() else {
                print("[AccountService] No user found")
                state.meta = nil
                return
            }
            
            state.meta = .init(user)
            state.addToProfiles = false
            state.authenticated = FederationKit.isAuthenticated()
            
            print("[AccountService] Logged in user: \(state.meta?.username)")
        }
    }
}
