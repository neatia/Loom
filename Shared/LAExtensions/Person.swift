//
//  Person.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import FederationKit

extension FederatedPersonResource: Identifiable {
    public var id: String {
        person.name + (person.domain ?? person.actor_id)
    }
}

extension FederatedPersonResource: Pageable {
    public var date: Date {
        .init()
    }
    
    public var blocked: Bool {
        Federation.isBlocked(self)
    }
}

extension FederatedPerson {
    func asView() -> FederatedPersonResource {
        .init(person: self, counts: .mock)
    }
}


extension FederatedPersonMentionResource: Pageable {
    public var id: String {
        "\(self.creator.id)\(self.comment.id)\(self.creator.domain ?? "")"
    }
    
    public var date: Date {
        self.comment.published.serverTimeAsDate ?? .init()
    }
    
    public var person: FederatedPerson {
        self.creator
    }
    
    public var blocked: Bool {
        self.creator_blocked
    }
}
