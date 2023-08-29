//
//  Post.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import LemmyKit

extension PostView: Pageable {
    public var id: String {
        "\(post.id)\(creator.actor_id)\(creator.name)\(post.ap_id)\(post.updated ?? "")"
    }
    
    public var date: Date {
        (
            self.post.updated ?? self.post.published
        ).serverTimeAsDate ?? Date()
    }
    
    public var blocked: Bool {
        creator_blocked
    }
    
    public var person: Person {
        self.creator
    }
    
    public var shouldHide: Bool {
        self.post.nsfw == true || self.community.nsfw == true
    }
    
    public var md5: String {
        let compiled = post.name + (post.body ?? "") + (post.url ?? "")
        return compiled.md5()
    }
}

extension PostView {
    func updateBlock(_ blocked: Bool, personView: PersonView) -> PostView {
        .init(post: self.post, creator: personView.person, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: blocked, unread_comments: self.unread_comments)
    }
    
    func updateRemoved() -> PostView {
        .init(post: self.post.updateRemoved(), creator: self.creator, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: self.creator_blocked, unread_comments: self.unread_comments)
    }
    
    func updateDeleted() -> PostView {
        .init(post: self.post.updateDeleted(), creator: self.creator, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: self.creator_blocked, unread_comments: self.unread_comments)
    }
}

extension Post {
    func updateRemoved() -> Post {
        .init(id: self.id, name: self.name, creator_id: self.creator_id, community_id: self.community_id, removed: !self.removed, locked: self.locked, published: self.published, deleted: self.deleted, nsfw: self.nsfw, ap_id: self.ap_id, local: self.local, language_id: self.language_id, featured_community: self.featured_community, featured_local: self.featured_local)
    }
    
    func updateDeleted() -> Post {
        .init(id: self.id, name: self.name, creator_id: self.creator_id, community_id: self.community_id, removed: self.removed, locked: self.locked, published: self.published, deleted: !self.deleted, nsfw: self.nsfw, ap_id: self.ap_id, local: self.local, language_id: self.language_id, featured_community: self.featured_community, featured_local: self.featured_local)
    }
}

extension PostView {
    var upvoteCount: Int {
        counts.upvotes
    }
    
    var downvoteCount: Int {
        counts.downvotes
    }
    
    var commentCount: Int {
        counts.comments
    }
    
    var avatarURL: URL? {
        return creator.avatarURL
    }
    
    var hasContent: Bool {
        post.body != nil || post.url != nil
    }
    
    var postURLString: String? {
        postURL?.host
    }
    
    public var postURL: URL? {
        if let urlString = post.url,
           let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    public var thumbURL: URL? {
        guard let url = post.thumbnail_url else {
            return nil
        }
        
        return URL(string: url)
    }
}

