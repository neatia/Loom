//
//  AccountMeta.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Granite
import Foundation
import FederationKit

struct AccountMeta: GranitePayload, GraniteModel, Identifiable, Hashable {
    static func ==(lhs: AccountMeta, rhs: AccountMeta) -> Bool {
        AccountModifyMeta.fromLocal(lhs.resource.user) == AccountModifyMeta.fromLocal(rhs.resource.user) && lhs.id == rhs.id
    }
    
    var resource: UserResource
    var host: String
    
    init(resource: UserResource, host: String) {
        self.resource = resource
        self.host = host
    }
    
    init(_ federationUser: FederationUser) {
        resource = federationUser.resource
        host = federationUser.host
    }
    
    var id: String {
        username + host
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AccountMeta {
    var person: FederatedPerson {
        resource.user.person
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
