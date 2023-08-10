//
//  MyUserInfo.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import LemmyKit

extension MyUserInfo {
    func updateBlocks(_ blocks: [PersonBlockView]) -> MyUserInfo {
        .init(local_user_view: self.local_user_view, follows: self.follows, moderates: self.moderates, community_blocks: self.community_blocks, person_blocks: blocks, discussion_languages: self.discussion_languages)
    }
}
