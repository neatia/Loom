//
//  Post.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import FederationKit

extension FederatedPostResource: Pageable {
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
    
    public var person: FederatedPerson {
        self.creator
    }
    
    public var shouldHide: Bool {
        let shouldHideNSFW: Bool = (self.post.nsfw == true || self.community.nsfw == true) && PagerFilter.enableForNSFW
        let shouldHideBot: Bool = self.creator.bot_account == true && PagerFilter.enableForBots
            
        let shouldHideKeywords: Bool
        if PagerFilter.enableForKeywords {
            shouldHideKeywords = PagerFilter.filterKeywords.check(post: self)
        } else {
            shouldHideKeywords = false
        }
        
        return shouldHideNSFW || shouldHideBot || shouldHideKeywords
    }
    
    public var md5: String {
        let compiled = post.name + (post.body ?? "") + (post.url ?? "")
        return compiled.md5()
    }
}

//TODO: clean and normalize all init cases
extension FederatedPostResource {
    func updateBlock(_ blocked: Bool, personView: FederatedPersonResource) -> FederatedPostResource {
        .init(post: self.post, creator: personView.person, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: blocked, unread_comments: self.unread_comments)
    }
    
    func updateRemoved() -> FederatedPostResource {
        .init(post: self.post.updateRemoved(), creator: self.creator, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: self.creator_blocked, unread_comments: self.unread_comments)
    }
    
    func updateDeleted() -> FederatedPostResource {
        .init(post: self.post.updateDeleted(), creator: self.creator, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: self.creator_blocked, unread_comments: self.unread_comments)
    }
}

extension FederatedPost {
    func updateRemoved() -> FederatedPost {
        .init(id: self.id, name: self.name, creator_id: self.creator_id, community_id: self.community_id, removed: !self.removed, locked: self.locked, published: self.published, deleted: self.deleted, nsfw: self.nsfw, ap_id: self.ap_id, local: self.local, language_id: self.language_id, featured_community: self.featured_community, featured_local: self.featured_local, instanceType: self.instanceType)
    }
    
    func updateDeleted() -> FederatedPost {
        .init(id: self.id, name: self.name, creator_id: self.creator_id, community_id: self.community_id, removed: self.removed, locked: self.locked, published: self.published, deleted: !self.deleted, nsfw: self.nsfw, ap_id: self.ap_id, local: self.local, language_id: self.language_id, featured_community: self.featured_community, featured_local: self.featured_local, instanceType: self.instanceType)
    }
}

extension FederatedPostResource {
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

