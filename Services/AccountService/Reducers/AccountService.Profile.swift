//
//  AccountService.Profile.swift
//  Lemur
//
//  Created by PEXAVC on 7/24/23.
//

import Foundation
import Granite
import LemmyKit
import IPFSKit

extension AccountService {
    struct Update: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Payload var meta: AccountModifyMeta?
        
        @Event var update: UpdateResponse.Reducer
        
        struct ResponseMeta: GranitePayload {
            var notification: StandardNotificationMeta
            var person: Person
        }
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            
            let username = state.meta?.username
            let host = state.meta?.host
            guard let auth = LemmyKit.auth else { return }
            _ = Task.detached {
                let info = await Lemmy.saveUserSettings(show_nsfw: meta.showNSFW,
                                                        show_scores: meta.showScores,
//                                                        theme: String? = nil,
                                                        default_sort_type: meta.sortType,
                                                        default_listing_type: meta.listingType,
//                                                        interface_language: String? = nil,
                                                        avatar: meta.avatar,
                                                        banner: meta.banner,
                                                        display_name: meta.displayName,
//                                                        email: String? = nil,
                                                        bio: meta.bio,
//                                                        matrix_user_id: String? = nil,
//                                                        show_avatars: Bool? = nil,
//                                                        send_notifications_to_email: Bool? = nil,
//                                                        bot_account: Bool? = nil,
                                                        show_bot_accounts: meta.showBotAccounts,
//                                                        show_read_posts: Bool? = nil,
//                                                        show_new_post_notifs: Bool? = nil,
//                                                        discussion_languages: [LanguageId]? = nil,
//                                                        generate_totp_2fa: Bool? = nil,
                                                        auth: auth//,
//                                                        open_links_in_new_tab: Bool? = nil
                                                        )
                
                guard let data = info?.jwt?.data(using: .utf8),
                          let username,
                          let host else {
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "ALERT_UPDATE_SETTINGS_FAILED", event: .error))
                    return
                }
                
                
                do {
                    try AccountService.insertToken(data, identifier: AccountService.keychainAuthToken + username, service: AccountService.keychainService + host)
                    LoomLog("inserted into keychain", level: .debug)
                } catch let error {
                    LoomLog("keychain: \(error)", level: .error)
                }
                
                if let user = LemmyKit.current.user?.local_user_view.person {
                    
                    beam.send(ResponseMeta(notification: StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_UPDATE_SETTINGS_SUCCESS", event: .success), person: user))
                    
                    update.send()
                }
            }
        }
    }
    
    struct UpdateResponse: GraniteReducer {
        typealias Center = AccountService.Center
        
        func reduce(state: inout Center.State) {
            guard let user = LemmyKit.current.user, let host = state.meta?.host else {
                LoomLog("no user found", level: .debug)
                state.meta = nil
                return
            }
            
            state.meta = .init(info: user, host: host)
        }
    }
}
