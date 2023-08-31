import Granite
import Foundation
import SwiftUI
import Security
import FederationKit

extension AccountService {
    enum AuthIntent {
        case login(String, String, String?)
        //TODO: needs to account for applications, verify pass
        case register(String, String, String?, String?)
    }
    struct Auth: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var intent: AuthIntent
            var addToProfiles: Bool = false
        }
        
        @Relay var bookmark: BookmarkService
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            guard let intent = meta?.intent else {
                return
            }
            
            let addToProfiles: Bool = meta?.addToProfiles ?? false
            switch intent {
            case .login(let username, let password, let token2FA):
                let info = await Federation.login(username: username,
                                                  password: password,
                                                  token2FA: token2FA)
                
                guard info != nil else {
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                    
                    return
                }
                
                guard setup(username, jwt: info, addToProfiles: addToProfiles),
                      let user = FederationKit.user() else {
                    return
                }
                
                ModalService.shared.dismissSheet()
                
                broadcast.send(
                    StandardNotificationMeta(title: "MISC_CONNECTED",
                                             message: "ALERT_CONNECTED_SUCCESS \("@"+username)",
                                             event: .success))
                
                state.meta = .init(user)
                state.addToProfiles = false
                state.authenticated = FederationKit.isAuthenticated()
                bookmark.center.boot.send()
                
            case .register(let username, let password, let captchaUUID, let captchaAnswer):
                let info = await Federation.register(username: username,
                                                     password: password,
                                                     password_verify: password,
                                                     show_nsfw: false,
                                                     captcha_uuid: captchaUUID,
                                                     captcha_answer: captchaAnswer)
                
                guard info != nil else {
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                    
                    return
                }
                
                guard setup(username, jwt: info, addToProfiles: addToProfiles),
                      let user = FederationKit.user() else {
                    return
                }
                
                state.meta = .init(user)
                state.addToProfiles = false
                state.authenticated = FederationKit.isAuthenticated()
            }
        }
        
        func setup(_ username: String, jwt: String?, addToProfiles: Bool) -> Bool {
            guard let jwt,
                  let data = jwt.data(using: .utf8) else {
                return false
            }
            
            do {
                try AccountService.insertToken(data,
                                               identifier: username,
                                               service: FederationKit.host)
                LoomLog("Auth | Boot | inserted into \(FederationKit.host) keychain", level: .debug)
                return true
            } catch let error {
                LoomLog("Auth | Boot | Error \(error.localizedDescription)", level: .error)
                return false
            }
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
    
    struct Logout: GraniteReducer {
        typealias Center = AccountService.Center
        
        func reduce(state: inout Center.State) {
            state.meta = nil
            state.authenticated = false
            FederationKit.logout()
        }
    }
}
