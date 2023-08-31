//
//  MyUserInfo.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import FederationKit

extension UserResource {
    func updateBlocks(_ blocks: [PersonRelationshipModel]) -> UserResource {
        .init(user: self.user,
              follows: self.follows,
              moderates: self.moderates,
              community_blocks: self.community_blocks,
              person_blocks: blocks,
              discussion_languages: self.discussion_languages,
              instanceType: self.instanceType)
    }
}
