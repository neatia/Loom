//
//  Comment.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import LemmyKit

extension CommentView: Pageable {
    public var date: Date {
        (
            self.comment.updated ?? self.comment.published
        ).serverTimeAsDate ?? Date()
    }
    
    public var blocked: Bool {
        creator_blocked
    }
    
    public var person: Person {
        creator
    }
    
    public var isAdmin: Bool {
        self.person.admin
    }
}

extension CommentView {
    func updateBlock(_ blocked: Bool, personView: PersonView) -> CommentView {
        .init(comment: self.comment, creator: personView.person, post: self.post, community: self.community, counts: self.counts, creator_banned_from_community: self.creator_banned_from_community, subscribed: self.subscribed, saved: self.saved, creator_blocked: blocked)
    }
}

extension CommentView: Identifiable {
    public var id: String {
        "\(creator.actor_id)\(creator.name)\(comment.ap_id)"
    }
    
    var avatarURL: URL? {
        creator.avatarURL
    }
    
    var replyCount: Int {
        counts.child_count
    }
    
    var upvoteCount: Int {
        counts.upvotes
    }
    
    var downvoteCount: Int {
        counts.downvotes
    }
}

extension CommentReplyView {
    var asCommentView: CommentView {
        .init(comment: comment, creator: creator, post: post, community: community, counts: counts, creator_banned_from_community: creator_banned_from_community, subscribed: subscribed, saved: saved, creator_blocked: creator_blocked)
    }
}

extension Comment {
    func asView(creator: Person, postView: PostView) -> CommentView {
        .init(comment: self, creator: creator, post: postView.post, community: postView.community, counts: .new(commentId: self.id, published: self.published), creator_banned_from_community: postView.creator_banned_from_community, subscribed: postView.subscribed, saved: false, creator_blocked: false)
    }
    
    func asView(with model: CommentView) -> CommentView {
        .init(comment: self, creator: model.creator, post: model.post, community: model.community, counts: model.counts, creator_banned_from_community: model.creator_banned_from_community, subscribed: model.subscribed, saved: model.saved, creator_blocked: model.creator_blocked)
    }
}

extension CommentAggregates {
    static func new(id: Int = 0, commentId: CommentId, published: String) -> CommentAggregates {
        .init(id: id, comment_id: commentId, score: 1, upvotes: 1, downvotes: 0, published: published, child_count: 0, hot_rank: 0)
    }
    
    func incrementReplyCount() -> CommentAggregates {
        .init(id: self.id, comment_id: self.comment_id, score: self.score, upvotes: self.upvotes, downvotes: self.downvotes, published: self.published, child_count: self.child_count + 1, hot_rank: self.hot_rank)
    }
}

extension CommentView {
    func incrementReplyCount() -> CommentView {
        .init(comment: self.comment, creator: self.creator, post: self.post, community: self.community, counts: self.counts.incrementReplyCount(), creator_banned_from_community: self.creator_banned_from_community, subscribed: self.subscribed, saved: self.saved, creator_blocked: self.creator_blocked)
    }
}
