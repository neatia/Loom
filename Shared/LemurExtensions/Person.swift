//
//  Person.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import LemmyKit

extension PersonView: Identifiable {
    public var id: String {
        person.name + (person.domain ?? person.actor_id)
    }
}

extension PersonView: Pageable {
    public var date: Date {
        .init()
    }
    
    public var blocked: Bool {
        //TODO: static access here, is not good practice
        let blocks = LemmyKit.current.user?.person_blocks
        return blocks?.first(where: { $0.target.equals(self.person) }) != nil
    }
}

extension Person {
    func asView() -> PersonView {
        .init(person: self, counts: .mock)
    }
}

extension PersonAggregates {
    static var mock: PersonAggregates {
        .init(id: 0, person_id: 0, post_count: 0, post_score: 0, comment_count: 0, comment_score: 0)
    }
}

extension Person {
    var domain: String? {
        URL(string: actor_id)?.hostString
    }
    
    public var isMe: Bool {
        domain == LemmyKit.current.user?.local_user_view.person.domain && name == LemmyKit.current.user?.local_user_view.person.name
    }
    
    public func equals(_ person: Person) -> Bool {
        return domain == person.domain && name == person.name
    }
}

extension Person {
    var avatarURL: URL? {
        if let urlString = avatar {
            return URL(string: urlString)
        }
        return nil
    }
}

extension PersonAggregates {
    var totalScore: Int {
        comment_score + post_score
    }
}

extension PersonMentionView: Pageable {
    public var id: String {
        "\(self.creator.id)\(self.comment.id)\(self.creator.domain ?? "")"
    }
    
    public var date: Date {
        self.comment.published.serverTimeAsDate ?? .init()
    }
    
    public var person: Person {
        self.creator
    }
    
    public var blocked: Bool {
        self.creator_blocked
    }
    
    public var asCommentView: CommentView {
        .init(comment: comment, creator: creator, post: post, community: community, counts: counts, creator_banned_from_community: creator_banned_from_community, subscribed: subscribed, saved: saved, creator_blocked: creator_blocked)
    }
}
