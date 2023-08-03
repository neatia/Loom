//
//  AccountMeta.swift
//  Lemur
//
//  Created by PEXAVC on 7/19/23.
//

import Granite
import Foundation
import LemmyKit

struct AccountMeta: GranitePayload, GraniteModel, Identifiable, Hashable {
    var info: MyUserInfo
    var host: String
    
    var id: String {
        username + host
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AccountMeta {
    var person: Person {
        info.local_user_view.person
    }
    
    var username: String {
        person.name
    }
    
    var avatarURL: URL? {
        person.avatarURL
    }
    
    var hostDisplay: String {
        //TODO: single regex
        host.replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .components(separatedBy: "/").first ?? ""
    }
}

extension MyUserInfo: GraniteModel {
    
}
