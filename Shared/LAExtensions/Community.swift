//
//  Community.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import FederationKit


extension FederatedCommunityResource: Pageable {
    public var date: Date {
        (
            self.community.updated ?? self.community.published
        ).serverTimeAsDate ?? Date()
    }
    
    public var person: FederatedPerson {
        .mock
    }
}

extension FederatedCommunity {
    func asView(isBlocked: Bool) -> FederatedCommunityResource {
        .init(community: self, subscribed: .notSubscribed, blocked: isBlocked, counts: .mock)
    }
}
