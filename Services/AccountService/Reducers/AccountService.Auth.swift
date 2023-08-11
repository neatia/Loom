import Granite
import Foundation
import SwiftUI
import LemmyKit
import Security

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
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) async {
            guard let intent = meta?.intent else {
                return
            }
            
            let addToProfiles: Bool = meta?.addToProfiles ?? false
            switch intent {
            case .login(let username, let password, let token2FA):
                let info = await Lemmy.login(username: username,
                                             password: password,
                                             token2FA: token2FA)
                
                guard info != nil else {
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                    
                    return
                }
                
                guard setup(username, jwt: info, addToProfiles: addToProfiles),
                      let user = LemmyKit.current.user else {
                    return
                }
                
                state.meta = .init(info: user, host: LemmyKit.host)
                state.addToProfiles = false
                state.authenticated = LemmyKit.auth != nil
                
            case .register(let username, let password, let captchaUUID, let captchaAnswer):
                let info = await Lemmy.register(username: username, password: password, password_verify: password, show_nsfw: false, captcha_uuid: captchaUUID, captcha_answer: captchaAnswer)
                
                guard info != nil else {
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_LOGIN_FAILED", event: .error))
                    
                    return
                }
                
                guard setup(username, jwt: info, addToProfiles: addToProfiles),
                      let user = LemmyKit.current.user else {
                    return
                }
                
                state.meta = .init(info: user, host: LemmyKit.host)
                state.addToProfiles = false
                state.authenticated = LemmyKit.auth != nil
            }
        }
        
        func setup(_ username: String, jwt: String?, addToProfiles: Bool) -> Bool {
            guard let jwt,
                  let data = jwt.data(using: .utf8) else {
                return false
            }
            
            do {
                try AccountService.insertToken(data,
                                               identifier: AccountService.keychainAuthToken + username,
                                               service: AccountService.keychainService + LemmyKit.host)
                print("{TEST} inserted data into keychain")
                return true
            } catch let error {
                print("{TEST} keychain: \(error)")
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
            LemmyKit.auth = nil
            state.authenticated = false
        }
    }
}
