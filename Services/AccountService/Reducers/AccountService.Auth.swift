import Granite
import Foundation
import SwiftUI
import LemmyKit
import Security

extension AccountService {
    enum AuthIntent {
        case login(String, String, String?)
        case register(String, String)
    }
    struct Auth: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var intent: AuthIntent
            var addToProfiles: Bool = false
        }
        
        @Payload var meta: Meta?
        
        @Event var response: AuthResponse.Reducer
        
        func reduce(state: inout Center.State) {
            guard let intent = meta?.intent else {
                return
            }
            
            let addToProfiles: Bool = meta?.addToProfiles ?? false
            switch intent {
            case .login(let username, let password, let token2FA):
                _ = Task.detached {
                    let info = await Lemmy.login(username: username,
                                                 password: password,
                                                 token2FA: token2FA)
                    
                    guard info != nil else {
                        beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                        
                        return
                    }
                    
                    response.send(AuthResponse.Meta(jwt: info, username: username, host: LemmyKit.host, addToProfiles: addToProfiles))
                }
            case .register:
                break
            }
        }
    }
    struct AuthResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var jwt: String?
            var username: String
            var host: String
            var addToProfiles: Bool
        }
        
        @Payload var meta: Meta?
        
        //TODO: Something is wrong with event afters
        //I think online reducers will mess up if the reducer
        //is mentioned elsewhere as well.
        @Event(.after) var details: Details.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta else {
                return
            }
            
            guard let jwt = meta.jwt else {
                return
            }
            
            guard let data = jwt.data(using: .utf8) else {
                return
            }
            
            do {
                try AccountService.insertToken(data, identifier: AccountService.keychainAuthToken + meta.username, service: AccountService.keychainService + meta.host)
                state.addToProfiles = meta.addToProfiles
                print("{TEST} inserted data into keychain")
            } catch let error {
                print("{TEST} keychain: \(error)")
            }
        }
    }
    
    struct Logout: GraniteReducer {
        typealias Center = AccountService.Center
        
        func reduce(state: inout Center.State) {
            state.meta = nil
        }
    }
}
