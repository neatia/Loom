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
        "\(post.id)\(creator.actor_id)\(creator.name)\(post.ap_id)"
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
}

extension PostView: Locateable {
    var isBaseResource: Bool {
        LemmyKit.host == community.actor_id.host
    }
    
    var isPeerResource: Bool {
        community.actor_id.host != creator.actor_id.host
    }
}

extension PostView {
    func updateBlock(_ blocked: Bool, personView: PersonView) -> PostView {
        .init(post: self.post, creator: personView.person, community: self.community, creator_banned_from_community: self.creator_banned_from_community, counts: self.counts, subscribed: self.subscribed, saved: self.saved, read: self.read, creator_blocked: blocked, unread_comments: self.unread_comments)
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
    
    var postURL: URL? {
        if let urlString = post.url,
           let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    public var thumbUrl: URL? {
        //Using LinkPresentation, it can generate thumbs via other sources
        /*guard let url = post.thumbnail_url else {
            return nil
        }*/
        
        return postURL
    }
}

