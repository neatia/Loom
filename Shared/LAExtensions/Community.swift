//
//  Community.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import LemmyKit

extension CommunityView: Pageable {
    public var date: Date {
        (
            self.community.updated ?? self.community.published
        ).serverTimeAsDate ?? Date()
    }
    
    public var person: Person {
        .mock
    }
}

extension CommunityView: Locateable {
    var isBaseResource: Bool {
        LemmyKit.host == community.actor_id.host
    }
    
    var isPeerResource: Bool {
        false
    }
    
    var displayName: String {
        self.community.displayName
    }
}

extension Community {
    func asView(isBlocked: Bool) -> CommunityView {
        .init(community: self, subscribed: .notSubscribed, blocked: isBlocked, counts: .mock)
    }
    
    var displayName: String {
        "!"+self.name+"@"+self.actor_id.host
    }
}

extension CommunityAggregates {
    static var mock: CommunityAggregates {
        .init(id: 0, community_id: 0, subscribers: 0, posts: 0, comments: 0, published: Date.today.asString, users_active_day: 0, users_active_week: 0, users_active_month: 0, users_active_half_year: 0, hot_rank: 0)
    }
}

extension Community {
    
    var iconURL: URL? {
        if let icon {
            return URL(string: icon)
        }
        
        return nil
    }
}
extension CommunityView: Identifiable {
    public var id: String {
        self.community.actor_id+"\(self.community.id)"
    }
    
    var iconURL: URL? {
        community.iconURL
    }
}

